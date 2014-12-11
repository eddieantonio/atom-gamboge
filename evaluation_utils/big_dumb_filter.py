import logging

COLORS = {
    'DEBUG': '46',
    'INFO': '46;1',
    'ERROR': '41;1',
    'WARNING': '43;1',
    'CRITICAL': '41;1'
}

class BigDumbFilter(object):
    """
    Only allows logs from only upload.
    """

    def filter(self, record):
        color = COLORS.get(record.levelname, '1')
        record.bgcolor = "\033[%sm" %(color,)
        return True
