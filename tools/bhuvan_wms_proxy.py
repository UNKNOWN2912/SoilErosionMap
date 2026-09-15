#!/usr/bin/env python3
"""
ISRO Bhuvan OGC WMS/WFS Proxy Service
Kerala Soil Erosion Monitor

Acts as a CORS-friendly caching gateway between the Flutter client and
ISRO Bhuvan NRSC geospatial servers (https://bhuvan.nrsc.gov.in).

Requirements:
    pip install fastapi uvicorn requests
"""

import os
import requests
from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(
    title="ISRO Bhuvan Proxy Gateway",
    description="CORS proxy for ISRO Bhuvan Soil Erosion and Land Degradation layers.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# FLAG: [ISRO BHUVAN CREDENTIALS]
# Obtain access token or user registration credentials from:
# https://bhuvan.nrsc.gov.in/bhuvan_links.php
BHUVAN_TOKEN = os.getenv("BHUVAN_TOKEN", "")
BHUVAN_WMS_BASE = "https://bhuvan-vec1.nrsc.gov.in/bhuvan/wms"

@app.get("/bhuvan/wms")
def proxy_bhuvan_wms(
    service: str = "WMS",
    version: str = "1.1.1",
    request: str = "GetMap",
    layers: str = "bhuvan:soil_erosion_kerala",
    bbox: str = "74.85,8.15,77.60,12.85",
    width: int = 256,
    height: int = 256,
    srs: str = "EPSG:4326",
    format: str = "image/png"
):
    """Proxies WMS tile requests to Bhuvan with authentication."""
    params = {
        "SERVICE": service,
        "VERSION": version,
        "REQUEST": request,
        "LAYERS": layers,
        "BBOX": bbox,
        "WIDTH": width,
        "HEIGHT": height,
        "SRS": srs,
        "FORMAT": format,
    }
    headers = {
        "User-Agent": "KeralaSoilErosionMonitor/1.0",
    }
    if BHUVAN_TOKEN:
        headers["Authorization"] = f"Bearer {BHUVAN_TOKEN}"

    try:
        resp = requests.get(BHUVAN_WMS_BASE, params=params, headers=headers, timeout=10)
        return Response(content=resp.content, media_type=resp.headers.get("content-type", format))
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Bhuvan gateway error: {e}")

if __name__ == "__main__":
    print("Starting ISRO Bhuvan Proxy Gateway on port 8001...")
    uvicorn.run(app, host="0.0.0.0", port=8001)
