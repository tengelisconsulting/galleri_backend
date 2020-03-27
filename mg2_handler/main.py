#!/usr/bin/env python3

import asyncio

from mg2.run import start_handler_loop


def main():
    asyncio.run(
        start_handler_loop()
    )


if __name__ == "__main__":
    main()
