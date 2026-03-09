#!/usr/bin/env python3
"""Fetch BTC/USDT kline data from Binance and save as monthly fixture CSV files."""

import os
import time
import csv
import urllib.request
import urllib.parse
import json
from datetime import datetime, timezone

BASE_URL = "https://api.binance.com/api/v3/klines"
SYMBOL = "BTCUSDT"
INTERVALS = ["5m", "15m", "1h"]
YEAR = 2023

MONTHS = [
    (1,  str(YEAR) + "-01-01", str(YEAR) + "-02-01"),
    (2,  str(YEAR) + "-02-01", str(YEAR) + "-03-01"),
    (3,  str(YEAR) + "-03-01", str(YEAR) + "-04-01"),
    (4,  str(YEAR) + "-04-01", str(YEAR) + "-05-01"),
    (5,  str(YEAR) + "-05-01", str(YEAR) + "-06-01"),
    (6,  str(YEAR) + "-06-01", str(YEAR) + "-07-01"),
    (7,  str(YEAR) + "-07-01", str(YEAR) + "-08-01"),
    (8,  str(YEAR) + "-08-01", str(YEAR) + "-09-01"),
    (9,  str(YEAR) + "-09-01", str(YEAR) + "-10-01"),
    (10, str(YEAR) + "-10-01", str(YEAR) + "-11-01"),
    (11, str(YEAR) + "-11-01", str(YEAR) + "-12-01"),
    (12, str(YEAR) + "-12-01", str(YEAR + 1) + "-01-01"),
]

def to_ms(date_str):
    dt = datetime.strptime(date_str, "%Y-%m-%d").replace(tzinfo=timezone.utc)
    return int(dt.timestamp() * 1000)

def fetch_klines(symbol, interval, start_ms, end_ms):
    """Fetch all klines for a given time range with pagination."""
    all_klines = []
    current_start = start_ms

    while current_start < end_ms:
        params = urllib.parse.urlencode({
            "symbol": symbol,
            "interval": interval,
            "startTime": current_start,
            "endTime": end_ms - 1,
            "limit": 1000,
        })
        url = f"{BASE_URL}?{params}"

        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read())

        if not data:
            break

        all_klines.extend(data)

        last_open_time = data[-1][0]
        if last_open_time == current_start:
            break
        current_start = last_open_time + 1

        if len(data) < 1000:
            break

        time.sleep(0.2)  # Rate limiting

    return all_klines

def save_csv(filepath, klines):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["open_time", "open", "high", "low", "close", "volume", "close_time"])
        for k in klines:
            writer.writerow([k[0], k[1], k[2], k[3], k[4], k[5], k[6]])

def main():
    base_dir = os.path.join(os.path.dirname(__file__), "..", "test", "fixtures")

    for month_num, start_date, end_date in MONTHS:
        folder_name = f"{YEAR}_{month_num:02d}"
        folder_path = os.path.join(base_dir, folder_name)
        start_ms = to_ms(start_date)
        end_ms = to_ms(end_date)

        print(f"\n=== {folder_name} ({start_date} to {end_date}) ===")

        for interval in INTERVALS:
            filepath = os.path.join(folder_path, f"kline_{interval}.csv")
            print(f"  Fetching {interval}...", end=" ", flush=True)

            klines = fetch_klines(SYMBOL, interval, start_ms, end_ms)
            save_csv(filepath, klines)

            print(f"{len(klines)} candles -> {filepath}")
            time.sleep(0.3)

    print("\nDone!")

if __name__ == "__main__":
    main()
