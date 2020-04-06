handler = Handler(send_spec='tcp://0.0.0.0:$SEND_PORT',
                       send_ident='$SEND_UUID',
                       recv_spec='tcp://0.0.0.0:$RECV_PORT', recv_ident='')

routes = {
    '/': handler
}

main = Server(
    uuid="$UUID",
    access_log="/logs/access.log",
    error_log="/logs/error.log",
    chroot="./",
    pid_file="/run/mongrel2.pid",
    default_host="localhost",
    name="mongrel",
    port=$PORT,
    hosts=[
        Host(name="localhost", routes=routes)
    ]
)

# settings = {
#     "limits.content_length": 1024 * 512
# }

servers = [main]
