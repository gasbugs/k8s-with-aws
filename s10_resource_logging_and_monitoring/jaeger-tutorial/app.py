import logging
import requests
from jaeger_client import Config

# Jaeger 라이브러리를 초기화합니다.
def init_tracer(service):
    config = Config(
        config={
            'sampler': {
                'type': 'const',
                'param': 1,
            },
            'local_agent': {
                'reporting_host': "127.0.0.1",
                'reporting_port': 6831,
            },
            'logging': True,
            'reporter_batch_size': 1,
        },

        service_name=service,
    )

    # this call also sets opentracing.tracer
    return config.initialize_tracer() 


tracer = init_tracer('first-service')

# 트레이싱을 시작합니다.
with tracer.start_span('get-ip-api-jobs') as span:
    try:
        res = requests.get('http://ip-api.com/json/naver.com')
        result = res.json()
        print('Getting status %s' % result['status'])
        span.set_tag('jobs-count', len(res.json()))
        for k in result.keys():
            span.set_tag(k, result[k])

    except:
        print('Unable to get site for')
