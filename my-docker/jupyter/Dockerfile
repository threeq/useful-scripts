FROM tensorflow/tensorflow

# install base 
RUN add-apt-repository ppa:longsleep/golang-backports \
    && apt-get update \
    && apt-get install -y python3-pip libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python3-tk git mercurial golang-go \
    && go version 
   
# upgrade pip
RUN python -m pip install --upgrade pip \
    && python3 -m pip install --upgrade pip

# intall ds
RUN python  -m pip install numpy matplotlib scipy sklearn pandas Pillow -i https://pypi.doubanio.com/simple
RUN python3 -m pip install numpy matplotlib scipy sklearn pandas Pillow -i https://pypi.doubanio.com/simple

## python TF
RUN pip3 install --upgrade tensorflow -i https://pypi.doubanio.com/simple
RUN pip  install --upgrade tensorflow -i https://pypi.doubanio.com/simple

## jupyter python3
RUN python3 -m pip install ipykernel \
    && python3 -m ipykernel install --user

# jupyter go
RUN export GOPATH=/go \
    && mkdir -p $GOPATH/src/golang.org/x \
    && cd $GOPATH/src/golang.org/x \
    && git clone https://github.com/golang/net.git net \ 
    && go install net \
    && git clone https://github.com/golang/image.git image \
    && go install image  \
    && git clone https://github.com/golang/exp.git exp \
    && git clone https://github.com/golang/tools.git tools 

## install gophernotes
RUN export GOPATH=/go \
    && go get github.com/gopherdata/gophernotes \
    && cp /go/bin/gophernotes /usr/local/bin/ \
    && mkdir -p ~/.local/share/jupyter/kernels/gophernotes \
    && cp -r /go/src/github.com/gopherdata/gophernotes/kernel/* ~/.local/share/jupyter/kernels/gophernotes \
    ## get the relevant Go packages
    && go get -insecure gonum.org/v1/plot/... \
    && go get -insecure gonum.org/v1/gonum/... \
    && go get github.com/kniren/gota/... \
    && go get github.com/sajari/regression \
    && go get github.com/sjwhitworth/golearn/... \
    && go get -insecure go-hep.org/x/hep/csvutil/... \
    && go get -insecure go-hep.org/x/hep/fit \
    && go get -insecure go-hep.org/x/hep/hbook \
    && go get github.com/montanaflynn/stats \
    && go get github.com/boltdb/bolt \
    && go get github.com/patrickmn/go-cache \
    && go get github.com/chewxy/math32 \
    && go get github.com/chewxy/hm \
    && go get github.com/chewxy/vecf64 \
    && go get github.com/chewxy/vecf32 \
    && go get github.com/awalterschulze/gographviz \
    && go get github.com/leesper/go_rng \
    && go get github.com/pkg/errors \
    && go get github.com/stretchr/testify/assert

## clean
RUN find /usr/lib/python3.5 -name __pycache__ | xargs rm -r \
    && rm -rf \
        /root/.[acpw]* \
        ipaexg00301* \
    && rm -rf /var/cache/apk/*

# Set GOPATH.
ENV GOPATH /go
ENV PASSWORD one@jupyter.me

