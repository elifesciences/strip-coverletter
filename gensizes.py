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
    # find the decapped and squashed versions
    matches = filter(lambda decap: decap.startswith(fname), decaps)
    if not matches:
        continue
    
    decap = squashed = None
    if len(matches) == 2:
        decap, squashed = sorted(matches)
        assert squashed.endswith('.pdf-squashed.pdf'), fname

    sizes = original_size, decap_size, squashed_size = size(join(pdfdir, fname)), size(join(decapdir, decap)), size(join(decapdir, squashed))


    
    if all(sizes):
        print "%s,%s,%s,%s" % (fname, original_size, decap_size, squashed_size)
    else:
        print 'skipping',fname,size
