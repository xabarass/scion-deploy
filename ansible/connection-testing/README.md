# Connection testing application

Running server: `./server <port>` 

Running client: `./client <config_file>`

Example of a config file:

```javascript
{
    "tests":[
        {
            "name":"ntp_test",
            "params":{
                "ntp_server":"2.ch.pool.ntp.org"
            }
        },
        {
            "name":"tcp_out",
            "params":{
                "host":"github.com",
                "port":"443",
                "request":"hello",
                "compare_response":false,
                "timeout":5
            }
        },
        {
            "name":"http_test",
            "params":{
                "host":"https://www.scion-architecture.net",
                "method":"GET",
                "timeout":10
            }
        },
        {
            "name":"tcp_out",
            "params":{
                "host":"www.zvv.ch",
                "port":"80",
                "request":"GET / HTTP/1.1\n\n",
                "compare_response":true,
                "timeout":10,
                "expected_response":"HTTP/1.1"
            }
        },
        {
            "name":"tcp_in",
            "params":{
                "host":"http://localhost:8080/tcp-test",
                "timeout":5,
                "my_port":"9999"
            }
        },
        {
            "name":"udp_in",
            "params":{
                "host":"http://localhost:8080/udp-test",
                "timeout":5,
                "my_port":"50000"
            }
        }
    ]
}
```

