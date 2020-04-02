import requests

import galleri.aws as aws


def main()-> None:
    req = aws.AwsReq(
        method = "GET",
        url = "https://s3.ca-central-1.amazonaws.com/galleri-storage-1/test3.file"
    )
    headers = aws.get_aws_headers(req)
    with requests.Session() as s:
        r = s.request(
            method = req.method,
            url = req.url,
            headers = headers,
            data = b"so many things"
        )
        print(r.text)


if __name__ == "__main__":
    main()
