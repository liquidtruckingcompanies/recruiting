"""Build data/county-drivers.json: truck-driver numbers for every county on the Hiring Map.

Runs in GitHub Actions (see .github/workflows/driver-data.yml), which can reach the government
data sites. Two free public sources:
  * BLS QCEW annual averages, NAICS 484 "Truck transportation" (private ownership):
    trucking companies, trucking jobs and average trucking pay located in each county.
    No key needed.
  * Census ACS 5-year microdata (PUMS), occupation 9130 "Driver/sales workers and truck
    drivers": people who LIVE in each county and work as truck drivers. The Census only
    publishes this for areas of 100,000+ people (PUMAs), so each area's count is split across
    its counties by population. The Census API needs a free key, saved as the repo secret CENSUS_API_KEY
    (sign up: https://api.census.gov/data/key_signup.html). Without it this part is skipped.
Whatever downloads is written, and the run log says what was used and what was missing.
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
# The Census doesn't publish its detailed "truck drivers" line for counties, only for areas of
# about 100,000+ people called PUMAs. So: count drivers per PUMA from the 5-year survey microdata
# (occupation 9130 "Driver/sales workers and truck drivers", employed), then split each PUMA's
# drivers across its census tracts by population and add the tracts up by county.
REL_URL = "https://www2.census.gov/geo/docs/maps-data/data/rel2020/2020_Census_Tract_to_2020_PUMA.txt"
STATES = sorted({f[:2] for f in IDS})


def api(url):
    raw = get(url + f"&key={KEY}")
    try:
        rows = json.loads(raw)
    except ValueError:
        raise RuntimeError(f"not data: {raw[:200]!r}")
    return rows[0], rows[1:]


def acs_drivers(y):
    base = f"https://api.census.gov/data/{y}/acs/acs5"
    pv = json.loads(get(f"{base}/pums/variables.json?key={KEY}"))["variables"]
    puma_var = next((v for v in ("PUMA20", "PUMA") if v in pv), None)
    if not puma_var:
        raise RuntimeError(f"no PUMA field in {y} PUMS: {[k for k in pv if 'PUMA' in k]}")
    rel = pd.read_csv(io.BytesIO(get(REL_URL)), dtype=str, encoding="utf-8-sig")
    rel.columns = [c.strip().upper() for c in rel.columns]
    rel["TRACT"] = rel["STATEFP"] + rel["COUNTYFP"] + rel["TRACTCE"]
    rel["PKEY"] = rel["STATEFP"] + rel["PUMA5CE"]
    tract_puma = dict(zip(rel["TRACT"], rel["PKEY"]))
    county_vals, n_states = {}, 0
    for st in STATES:
        try:
            # Employed truck drivers (ESR 1 civilian at work, 2 civilian with a job) and their weights.
            h, rows = api(f"{base}/pums?get=PWGTP,{puma_var},ESR&OCCP=9130&for=state:{st}")
            drivers = {}
            for r in rows:
                d = dict(zip(h, r))
                if d["ESR"] not in ("1", "2"):
                    continue
                k = st + str(d[puma_var]).zfill(5)
                drivers[k] = drivers.get(k, 0) + int(d["PWGTP"])
            h, rows = api(f"{base}?get=B01003_001E&for=tract:*&in=state:{st}")
        except Exception as e:
            print(f"ACS {y} state {st}: {e}")
            continue
        tpop, ppop = {}, {}
        for r in rows:
            d = dict(zip(h, r))
            t = d["state"] + d["county"] + d["tract"]
            p = max(int(float(d["B01003_001E"] or 0)), 0)
            k = tract_puma.get(t)
            if k is None:
                continue
            tpop[t] = (k, p)
            ppop[k] = ppop.get(k, 0) + p
        for t, (k, p) in tpop.items():
            if ppop.get(k) and k in drivers:
                c = t[:5]
                county_vals[c] = county_vals.get(c, 0) + drivers[k] * p / ppop[k]
        n_states += 1
        print(f"ACS {y} state {st}: {sum(drivers.values()):,} drivers in {len(drivers)} PUMAs")
    return county_vals, n_states


if not KEY:
    print("ACS: skipped, no CENSUS_API_KEY secret (free key: https://api.census.gov/data/key_signup.html)")
else:
    for y in range(THIS_YEAR - 1, THIS_YEAR - 5, -1):
        try:
            vals, n_states = acs_drivers(y)
        except Exception as e:
            print(f"ACS {y}: {e}")
            continue
        n = 0
        for f, v in vals.items():
            if f in out and v >= 1:
                out[f]["live"] = int(round(v, -1)) if v >= 100 else int(round(v))
                n += 1
        print(f"ACS {y}: {n} counties from {n_states} states; nationwide {sum(vals.values()):,.0f} drivers")
        if n < len(IDS) * 0.9:
            print(f"ACS {y}: too few counties, not using it")
            for f in out:
                out[f].pop("live", None)
            continue
        sources["acs"] = {"label": f"U.S. Census American Community Survey 5-year microdata {y-4}-{y}, employed driver/sales workers and truck drivers (occupation 9130) by home area, split into counties by population",
                          "years": f"{y-4}-{y}", "href": "https://www.census.gov/programs-surveys/acs/microdata.html"}
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
