"""Build data/county-drivers.json: truck-driver numbers for every county on the Hiring Map.

Runs in GitHub Actions (see .github/workflows/driver-data.yml), which can reach the government
data sites. Two free public sources:
  * BLS QCEW annual averages, NAICS 484 "Truck transportation" (private ownership):
    trucking companies, trucking jobs and average trucking pay located in each county.
    No key needed.
  * Census ACS 5-year, table B24114 line 541 "Driver/sales workers and truck drivers":
    people who LIVE in each county and work as truck drivers, with margin of error.
    The Census API needs a free key, saved as the repo secret CENSUS_API_KEY
    (sign up: https://api.census.gov/data/key_signup.html). Without it this part is skipped.
Whatever downloads is written; the run log says what was used and what was missing.
The site never shows a source that failed, so a partial run is safe.
"""
import io, json, os, sys, time, datetime
import urllib.request, urllib.error
import pandas as pd

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UA = {"User-Agent": "LiquidTruckingRecruitingData/1.0 (+https://github.com/liquidtruckingcompanies/recruiting)", "Accept": "*/*"}
KEY = os.environ.get("CENSUS_API_KEY", "").strip()
THIS_YEAR = datetime.date.today().year
OUT = os.path.join(ROOT, "data/county-drivers.json")


def get(url, tries=3):
    last = None
    for i in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=120) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            last = f"HTTP {e.code}: {e.read()[:200]!r}"
            if e.code in (400, 403, 404):
                break
        except Exception as e:  # network hiccup: retry
            last = e
        time.sleep(3 * (i + 1))
    raise RuntimeError(f"{url.split('&key=')[0]}: {last}")


counties = json.load(open(os.path.join(ROOT, "data/counties.json")))
IDS = [c["id"] for c in counties]
NAME = {c["id"]: c["n"] for c in counties}
out = {c: {} for c in IDS}
sources = {}
# Keep the previous file's numbers for any source that fails this time.
try:
    prev = json.load(open(OUT))
except Exception:
    prev = {"sources": {}, "c": {}}

# ---------- BLS QCEW: trucking companies, jobs and pay by county ----------
for y in range(THIS_YEAR, THIS_YEAR - 4, -1):
    try:
        df = pd.read_csv(io.BytesIO(get(f"https://data.bls.gov/cew/data/api/{y}/a/industry/484.csv")), dtype=str)
    except Exception as e:
        print(f"QCEW {y}: {e}")
        continue
    df = df[(df["own_code"] == "5") & (df["agglvl_code"] == "75")]  # private, county level
    got = 0
    for _, r in df.iterrows():
        f = r["area_fips"]
        if f not in out:
            continue
        firms = int(float(r["annual_avg_estabs"]))
        if not firms:
            continue
        out[f]["firms"] = firms
        if r["disclosure_code"] != "N":  # "N" = kept private for small counties
            jobs = int(float(r["annual_avg_emplvl"]))
            wk = float(r["annual_avg_wkly_wage"])
            if jobs:
                out[f]["jobs"] = jobs
            if wk:
                out[f]["pay"] = int(round(wk * 52, -2))
        got += 1
    print(f"QCEW {y}: {got} of {len(IDS)} map counties have trucking companies")
    sources["qcew"] = {"label": f"BLS Quarterly Census of Employment and Wages, {y} annual average, NAICS 484 Truck transportation",
                       "year": str(y), "href": "https://www.bls.gov/cew/"}
    break


# ---------- Census ACS: truck drivers who live in each county ----------
def acs(year, var, geo):
    url = f"https://api.census.gov/data/{year}/acs/acs5?get={var}&{geo}&key={KEY}"
    raw = get(url)
    try:
        rows = json.loads(raw)
    except ValueError:
        raise RuntimeError(f"ACS {year}: not data: {raw[:200]!r}")
    return rows[0], rows[1:]


def acs_fill(year, only=None):
    head, rows = acs(year, "B24114_541E,B24114_541M", "for=county:*&in=state:*")
    n = 0
    for r in rows:
        d = dict(zip(head, r))
        f = d["state"] + d["county"]
        if f not in out or (only is not None and f not in only):
            continue
        try:
            est, moe = float(d["B24114_541E"]), float(d["B24114_541M"])
        except (TypeError, ValueError):
            continue
        if est < 0:
            continue
        out[f]["live"] = int(est)
        if moe >= 0:
            out[f]["liveMoe"] = int(moe)
        if only is not None:
            out[f]["liveYears"] = f"{year-4}-{year}"
        n += 1
    return n


if not KEY:
    print("ACS: skipped, no CENSUS_API_KEY secret (free key: https://api.census.gov/data/key_signup.html)")
else:
    for y in range(THIS_YEAR - 1, THIS_YEAR - 5, -1):
        try:
            n = acs_fill(y)
        except Exception as e:
            print(f"ACS {y}: {e}")
            continue
        missing = [f for f in IDS if "live" not in out[f]]
        print(f"ACS {y}: {n} counties; missing {len(missing)} {missing[:12]}")
        # Connecticut's 8 old counties became planning regions in the 2022+ ACS; the map still
        # draws the old counties, so fill them from the last 5-year release that has them.
        if missing and y >= 2022:
            try:
                print(f"ACS 2021 fallback: {acs_fill(2021, set(missing))} counties")
            except Exception as e:
                print(f"ACS 2021 fallback: {e}")
        sources["acs"] = {"label": f"U.S. Census American Community Survey 5-year {y-4}-{y}, driver/sales workers and truck drivers by county of residence",
                          "years": f"{y-4}-{y}", "href": f"https://data.census.gov/table/ACSDT5Y{y}.B24114"}
        break

# Carry forward any source that failed this run but worked before.
for k, keys in (("qcew", ("firms", "jobs", "pay")), ("acs", ("live", "liveMoe", "liveYears"))):
    if k not in sources and k in prev.get("sources", {}):
        print(f"{k}: keeping last run's numbers")
        sources[k] = prev["sources"][k]
        for f, v in prev.get("c", {}).items():
            if f in out:
                out[f].update({x: v[x] for x in keys if x in v})

res = {"updated": datetime.date.today().isoformat(), "sources": sources, "c": {f: v for f, v in out.items() if v}}
with open(OUT, "w") as fh:
    json.dump(res, fh, separators=(",", ":"))
print("wrote", OUT, os.path.getsize(OUT), "bytes;", len(res["c"]), "counties")
for f in ["19153", "31055", "29095", "17031", "48201", "09003"]:
    print(" ", f, NAME.get(f), out.get(f))
if not sources:
    sys.exit("No source downloaded")
