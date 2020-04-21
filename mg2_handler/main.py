#!/usr/bin/env python3

import asyncio

from mg2.run import start_handler_loop

from init import init_app


def main():
    app = init_app()
    asyncio.run(
        start_handler_loop(app)
    )


if __name__ == "__main__":
    main()
