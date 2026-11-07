"""Temporary: check which Census PUMS fields and files are available. Removed before merge."""
import json, os, urllib.request, urllib.error
KEY = os.environ.get("CENSUS_API_KEY", "").strip()
UA = {"User-Agent": "LiquidTruckingRecruitingData/1.0"}


def peek(url, n=400):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=120) as r:
            b = r.read(); print("OK", r.status, len(b), url.split("&key=")[0], "\n  ", b[:n]); return b
    except urllib.error.HTTPError as e:
        print("HTTP", e.code, url.split("&key=")[0], "\n  ", e.read()[:n])
    except Exception as e:
        print("ERR", url.split("&key=")[0], e)


A = "https://api.census.gov/data"
for y in (2024, 2023):
    b = peek(f"{A}/{y}/acs/acs5/pums/variables.json", 0)
    if b:
        v = json.loads(b)["variables"]
        print(y, "PUMA vars:", {k: v[k].get("label") for k in v if "PUMA" in k.upper()})
        print(y, "OCCP 9130:", (v.get("OCCP", {}).get("values", {}).get("item", {}) or {}).get("9130"))
    peek(f"{A}/{y}/acs/acs5/pums/geography.json", 1500)
    peek(f"{A}/{y}/acs/acs5/pums?get=PWGTP,PUMA&OCCP=9130&for=state:19&key={KEY}", 300)
    peek(f"{A}/{y}/acs/acs5/pums?get=PWGTP&OCCP=9130&for=public%20use%20microdata%20area:*&in=state:19&key={KEY}", 300)
peek(f"{A}/2024/acs/acs5?get=B01003_001E&for=tract:*&in=state:19&key={KEY}", 200)
peek("https://www2.census.gov/geo/docs/maps-data/data/rel2020/2020_Census_Tract_to_2020_PUMA.txt", 300)
