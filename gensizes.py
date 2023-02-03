import os
from os.path import join
pdfdir = "bucket-pdf"
decapdir = "bucket-pdf-decap"

fnames = os.listdir(pdfdir)
decaps = os.listdir(decapdir)

def size(path):
    if path:
        return os.path.getsize(path)

for fname in fnames:
    # find the decapped version
    matches = filter(lambda decap: decap.startswith(fname), decaps)
    if not matches:
        continue
    
    decap = matches[0]
    original_size, decap_size = size(join(pdfdir, fname)), size(join(decapdir, decap))
    if original_size and decap_size:
        print "%s,%s,%s,%s" % (fname, original_size, decap_size)
    else:
        print 'skipping',fname,size
