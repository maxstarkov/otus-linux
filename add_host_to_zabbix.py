from pyzabbix import ZabbixAPI

zapi = ZabbixAPI(url='http://192.168.33.10', user='Admin', password='zabbix')

res = zapi.do_request(method='host.create', params={
    "host": "simple-host",
    "interfaces": [
        {
            "type": 1,
            "main": 1,
            "useip": 1,
            "ip": "192.168.33.11",
            "dns": "",
            "port": "10050"
        }
    ],
    "groups": [
        {
            "groupid": "2"
        }
    ],
    "templates": [
        {
            "templateid": "10001"
        }
    ],
    }
)
