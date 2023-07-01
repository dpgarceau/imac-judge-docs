FROM sphinxdoc/sphinx-latexpdf

WORKDIR /docs
ADD docs/requirements.txt /docs
RUN pip3 install -r requirements.txt
