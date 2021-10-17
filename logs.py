import logging
import random
import sys
import time

# Писать логи контейнера будем в STDOUT. Разбивать по severity будем при помощи парсера в Fluent-bit
import uuid

logger = logging.getLogger(__name__)

# Зададим форматер чтобы позже по этому же шаблону парсить логи.
formatter = logging.Formatter(
    '[req_id=%(req_id)s] [%(levelname)s] %(code)d %(message)s'
)

handler = logging.StreamHandler(stream=sys.stdout)
handler.setFormatter(formatter)

logger.addHandler(handler)

# Опционально можно настроить уровень логирования по умолчанию
logger.setLevel(logging.DEBUG)

# Мы могли бы обойтись и простым логированием случайных чисел, но я решил генерировать URL-подобные значения.
PATHS = [
    '/',
    '/admin',
    '/hello',
    '/docs',
]

PARAMS = [
    'foo',
    'bar',
    'query',
    'search',
    None
]


def fake_url():
    path = random.choice(PATHS)
    param = random.choice(PARAMS)
    if param:
        val = random.randint(0, 100)
        param += '=%s' % val
    code = random.choices([200, 400, 404, 500], weights=[10, 2, 2, 1])[0]
    return '?'.join(filter(None, [path, param])), code


if __name__ == '__main__':
    while True:
        req_id = uuid.uuid4()
        # создаем пару код и значение URL
        path, code = fake_url()
        extra = {"code": code, "req_id": req_id}
        # Если код 200, то пишем в  лог с уровнем Info
        if code == 200:
            logger.info(
                'Path: %s',
                path,
                extra=extra,
            )
        # Иначе с уровнем Error
        else:
            logger.error(
                'Error: %s',
                path,
                extra=extra,
            )
        # Чтобы можно было погрепать несколько сообщение по одному request id в 30% случаев будем писать вторую запись
        # в лог с уровнем Debug.
        if random.random() > 0.7:
            logger.debug("some additional debug log record %f", random.random(), extra=extra)

        # Ждем 1 секунду, чтобы излишне не засорять журнал
        time.sleep(1)
