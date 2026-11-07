"""Build data/county-drivers.json: truck-driver numbers for every county on the Hiring Map.

Runs in GitHub Actions (see .github/workflows/driver-data.yml) because it downloads public
government data:
  * Census ACS 5-year, table B24114 line 541 "Driver/sales workers and truck drivers":
    people who live in the county and work as truck drivers (with margin of error).
  * BLS OEWS (May survey), SOC 53-3032 "Heavy and tractor-trailer truck drivers":
    jobs and annual wages for the metro area (or rural part of the state) the county is in.
  * BLS QCEW annual averages, NAICS 484 "Truck transportation" (private): trucking
    companies and trucking jobs located in the county.
Each source is optional; whatever downloads is written, and the run log says what was used.
"""
import io, json, os, re, sys, time, zipfile, datetime
import urllib.request, urllib.error
import pandas as pd

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UA = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36",
      "Accept": "*/*", "Accept-Language": "en-US,en;q=0.9"}
KEY = os.environ.get("CENSUS_API_KEY", "").strip()
THIS_YEAR = datetime.date.today().year


def get(url, tries=3):
    last = None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=120) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            last = e
            if e.code in (404, 400, 204):
                break
        except Exception as e:  # network hiccup
            last = e
        time.sleep(3 * (i + 1))
    raise RuntimeError(f"{url}: {last}")


counties = json.load(open(os.path.join(ROOT, "data/counties.json")))
IDS = [c["id"] for c in counties]
NAME = {c["id"]: c["n"] for c in counties}
out = {c: {} for c in IDS}
sources = {}

# ---------- Census ACS ----------
def acs(year, var, geo="for=county:*&in=state:*"):
    url = f"https://api.census.gov/data/{year}/acs/acs5?get={var}&{geo}" + (f"&key={KEY}" if KEY else "")
    rows = json.loads(get(url))
    head, rows = rows[0], rows[1:]
    return head, rows

acs_year = None
for y in range(THIS_YEAR - 1, THIS_YEAR - 5, -1):
    try:
        head, rows = acs(y, "B24114_541E,B24114_541M")
        acs_year = y
        break
    except Exception as e:
        print(f"ACS {y}: {e}")
if acs_year:
    got = 0
    for r in rows:
        d = dict(zip(head, r))
        f = d["state"] + d["county"]
        if f in out and d["B24114_541E"] not in (None, "", "-666666666"):
            try:
                out[f]["live"] = int(float(d["B24114_541E"]))
                m = float(d["B24114_541M"])
                if m >= 0: out[f]["liveMoe"] = int(m)
                got += 1
            except ValueError:
                pass
    missing = [f for f in IDS if "live" not in out[f]]
    print(f"ACS {acs_year}: {got} counties, missing {len(missing)}: {missing[:20]}")
    # Connecticut switched to planning regions in 2022; the map still has the 8 old counties.
    if missing:
        for y in range(min(acs_year, 2021), 2017, -1):
            try:
                head, rows = acs(y, "B24114_541E,B24114_541M")
            except Exception as e:
                print(f"ACS {y} (fallback): {e}"); continue
            for r in rows:
                d = dict(zip(head, r)); f = d["state"] + d["county"]
                if f in missing and d["B24114_541E"] not in (None, ""):
                    out[f]["live"] = int(float(d["B24114_541E"]))
                    out[f]["liveMoe"] = int(float(d["B24114_541M"])) if float(d["B24114_541M"]) >= 0 else None
                    out[f]["liveYear"] = f"{y-4}-{y}"
            print(f"ACS fallback {y}: still missing {[f for f in IDS if 'live' not in out[f]]}")
            break
    sources["acs"] = {"label": f"Census ACS 5-year {acs_year-4}-{acs_year}", "years": f"{acs_year-4}-{acs_year}",
                      "href": f"https://data.census.gov/table/ACSDT5Y{acs_year}.B24114"}

# ---------- BLS QCEW (NAICS 484, private) ----------
for y in range(THIS_YEAR, THIS_YEAR - 4, -1):
    try:
        df = pd.read_csv(io.BytesIO(get(f"https://data.bls.gov/cew/data/api/{y}/a/industry/484.csv")), dtype=str)
    except Exception as e:
        print(f"QCEW {y}: {e}"); continue
    df = df[(df["own_code"] == "5") & (df["agglvl_code"] == "75")]
    got = 0
    for _, r in df.iterrows():
        f = r["area_fips"]
        if f not in out: continue
        out[f]["firms"] = int(float(r["annual_avg_estabs"]))
        if r.get("disclosure_code", "") != "N":
            out[f]["jobs"] = int(float(r["annual_avg_emplvl"]))
        got += 1
    print(f"QCEW {y}: {got} counties with trucking firms; columns {list(df.columns)[:14]}")
    sources["qcew"] = {"label": f"BLS QCEW {y} annual average, NAICS 484 Truck transportation", "year": str(y),
                       "href": "https://www.bls.gov/cew/"}
    break

# ---------- BLS OEWS (53-3032 by metro / nonmetro area) ----------
areas = []
for y in range(THIS_YEAR, THIS_YEAR - 4, -1):
    yy = str(y)[2:]
    try:
        z = zipfile.ZipFile(io.BytesIO(get(f"https://www.bls.gov/oes/special-requests/oesm{yy}ma.zip")))
    except Exception as e:
        print(f"OEWS {y} data: {e}"); continue
    print("OEWS zip:", z.namelist())
    name = [n for n in z.namelist() if n.lower().endswith((".xlsx", ".xls")) and "msa" in n.lower() and "dl" in n.lower()] or \
           [n for n in z.namelist() if n.lower().endswith((".xlsx", ".xls"))]
    frames = []
    for n in name:
        frames.append(pd.read_excel(z.open(n), dtype=str))
    data = pd.concat(frames)
    data.columns = [c.upper() for c in data.columns]
    print("OEWS columns:", list(data.columns))
    data = data[data["OCC_CODE"] == "53-3032"]
    try:
        defs_raw = get(f"https://www.bls.gov/oes/{y}/may/area_definitions_m{y}.xlsx")
    except Exception as e:
        print(f"OEWS {y} area definitions: {e}"); continue
    defs = pd.read_excel(io.BytesIO(defs_raw), dtype=str)
    print("OEWS defs columns:", list(defs.columns)); print(defs.head(3).to_string())
    cols = {c.lower(): c for c in defs.columns}
    def col(*keys):
        for k, v in cols.items():
            if all(x in k for x in keys): return v
        raise KeyError(keys)
    c_st, c_cty = col("fips"), col("county code")
    c_area = [v for k, v in cols.items() if "code" in k and ("msa" in k or "area" in k) and "county" not in k and "fips" not in k][0]
    idx = {}
    for _, r in data.iterrows():
        def num(v):
            try: return int(float(str(v).replace(",", "")))
            except ValueError: return None
        idx[str(r["AREA"]).strip()] = len(areas)
        areas.append([str(r["AREA_TITLE"]).strip(), num(r["TOT_EMP"]), num(r["A_MEDIAN"]), num(r["A_MEAN"])])
    got = 0
    for _, r in defs.iterrows():
        f = str(r[c_st]).zfill(2) + str(r[c_cty]).zfill(3)
        a = str(r[c_area]).strip().lstrip("0") if False else str(r[c_area]).strip()
        k = a if a in idx else a.lstrip("0")
        if f in out and k in idx:
            out[f]["area"] = idx[k]; got += 1
    print(f"OEWS {y}: {len(areas)} areas with 53-3032, {got} counties mapped; missing {[f for f in IDS if 'area' not in out[f]][:30]}")
    sources["oews"] = {"label": f"BLS OEWS May {y}, Heavy and tractor-trailer truck drivers (53-3032)", "year": str(y),
                       "href": "https://www.bls.gov/oes/current/oes533032.htm"}
    break

res = {"updated": datetime.date.today().isoformat(), "sources": sources, "areas": areas,
       "c": {f: v for f, v in out.items() if v}}
p = os.path.join(ROOT, "data/county-drivers.json")
json.dump(res, open(p, "w"), separators=(",", ":"))
print("wrote", p, os.path.getsize(p), "bytes;", len(res["c"]), "counties")
for f in ["19153", "31055", "29095", "17031", "48201"]:
    print(f, NAME.get(f), out.get(f), areas[out[f]["area"]] if "area" in out.get(f, {}) else None)
if not sources:
    sys.exit("No source downloaded")
