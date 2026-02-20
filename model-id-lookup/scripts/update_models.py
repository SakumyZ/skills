#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Model Schema Updater

This script fetches the latest model schema from models.dev and updates
the local reference file.

Usage:
    python update_models.py
"""

import json
import urllib.request
import urllib.error
import os
import sys
from datetime import datetime


def fetch_model_schema(url: str = "https://models.dev/model-schema.json") -> dict:
    """
    Fetch the latest model schema from the remote URL.

    Args:
        url: The URL to fetch the schema from

    Returns:
        The parsed JSON data

    Raises:
        urllib.error.URLError: If the request fails
        json.JSONDecodeError: If the response is not valid JSON
    """
    print(f"Fetching model schema from: {url}")

    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    }

    request = urllib.request.Request(url, headers=headers)

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            if response.status != 200:
                raise urllib.error.URLError(f"HTTP {response.status}")

            data = json.loads(response.read().decode("utf-8"))
            print("[OK] Successfully fetched schema")
            return data

    except urllib.error.HTTPError as e:
        raise urllib.error.URLError(f"HTTP Error {e.code}: {e.reason}")
    except urllib.error.URLError as e:
        raise urllib.error.URLError(f"Network error: {e.reason}")


def validate_schema(data: dict) -> bool:
    """
    Validate that the schema has the expected structure.

    Args:
        data: The parsed JSON data

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(data, dict):
        print("[ERROR] Response is not a valid JSON object")
        return False

    if "$defs" not in data:
        print("[ERROR] Missing '$defs' key in schema")
        return False

    if "Model" not in data.get("$defs", {}):
        print("[ERROR] Missing 'Model' definition in schema")
        return False

    model_def = data["$defs"]["Model"]
    if "enum" not in model_def:
        print("[ERROR] Missing 'enum' in Model definition")
        return False

    if not isinstance(model_def["enum"], list):
        print("[ERROR] 'enum' is not a list")
        return False

    model_count = len(model_def["enum"])
    print(f"[OK] Schema validated: {model_count} models found")
    return True


def save_schema(data: dict, filepath: str) -> None:
    """
    Save the schema to the local file.

    Args:
        data: The schema data to save
        filepath: The path to save to
    """
    # Ensure directory exists
    os.makedirs(os.path.dirname(filepath), exist_ok=True)

    # Save with pretty formatting
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False, sort_keys=True)

    print(f"[OK] Schema saved to: {filepath}")


def get_script_dir() -> str:
    """Get the directory where this script is located."""
    return os.path.dirname(os.path.abspath(__file__))


def main():
    """Main entry point."""
    print("=" * 60)
    print("Model Schema Updater")
    print("=" * 60)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Configuration
    url = "https://models.dev/model-schema.json"
    script_dir = get_script_dir()
    output_path = os.path.join(script_dir, "..", "references", "model-schema.json")
    output_path = os.path.normpath(output_path)

    print(f"Target file: {output_path}")
    print()

    try:
        # Fetch the schema
        data = fetch_model_schema(url)

        # Validate the schema
        if not validate_schema(data):
            print("\n[ERROR] Schema validation failed. Update cancelled.")
            sys.exit(1)

        # Save the schema
        save_schema(data, output_path)

        # Print summary
        model_count = len(data["$defs"]["Model"]["enum"])
        print()
        print("=" * 60)
        print("Update completed successfully!")
        print("=" * 60)
        print(f"Total models: {model_count}")
        print(f"Schema version: {data.get('$id', 'N/A')}")
        print()

        # Show sample models
        print("Sample models:")
        sample_models = data["$defs"]["Model"]["enum"][:5]
        for model in sample_models:
            print(f"  - {model}")

        if model_count > 5:
            print(f"  ... and {model_count - 5} more")

        print()

    except urllib.error.URLError as e:
        print(f"\n[ERROR] Network error: {e}")
        print("\nPlease check your internet connection and try again.")
        sys.exit(1)

    except json.JSONDecodeError as e:
        print(f"\n[ERROR] JSON parsing error: {e}")
        print("\nThe server response was not valid JSON.")
        sys.exit(1)

    except Exception as e:
        print(f"\n[ERROR] Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
