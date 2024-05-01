FROM debian:bookworm-slim

ARG USER_NAME=root
ARG PYENV_ROOT=
ARG PYTHON_CONFIGURE_OPTS=/root/.pyenv
ARG PYTHON_CFLAGS=
ARG PROFILE_TASK="-m test.regrtest --pgo -j0"
ARG DEFAULT_PACKAGES=

ENV USER_NAME=$USER_NAME \
    PYTHON_CONFIGURE_OPTS=$PYTHON_CONFIGURE_OPTS \
    PYENV_ROOT=$PYENV_ROOT \
    PYTHON_CFLAGS=$PYTHON_CFLAGS \
    PROFILE_TASK=$PROFILE_TASK \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_NO_CACHE=true \
    UV_SYSTEM_PYTHON=true \
    PATH=/home/$USER_NAME/.cargo/bin:$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN printenv

RUN apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    ca-certificates git make \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev

RUN useradd -ms /bin/bash $USER_NAME
USER $USER_NAME

WORKDIR $PYENV_ROOT
# Clone and atch pyenv for correct --without-ensurepip
RUN git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT \ 
    && sed -i 's/ensurepip//g' $PYENV_ROOT/plugins/python-build/share/python-build/3.* \
    && sed -i 's/copy_python_gdb//g' $PYENV_ROOT/plugins/python-build/share/python-build/3.* \
    && git clone https://github.com/pyenv/pyenv-update.git $PYENV_ROOT/plugins/pyenv-update \
    && cd $PYENV_ROOT \
    && src/configure && make -C src \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && pyenv --version \
    && uv --version

RUN pyenv install --verbose 3.9 \
    && pyenv global 3.9 \
    && python --version \
    && uv pip --no-cache install $DEFAULT_PACKAGES \
    && pyenv rehash \
    && poetry --version \
    && find $PYENV_ROOT/versions/3.9*/* -name '__pycache__' | xargs rm -r

RUN pyenv install --verbose 3.11 \
    && pyenv global 3.11 \
    && python --version \
    && uv pip --no-cache install $DEFAULT_PACKAGES \
    && pyenv rehash \
    && poetry --version \
    && find $PYENV_ROOT/versions/3.11*/* -name '__pycache__' | xargs rm -r


RUN pyenv install --verbose 3.12 \
    && pyenv global 3.12 \
    && python --version \
    && uv pip --no-cache install $DEFAULT_PACKAGES \
    && pyenv rehash \
    && poetry --version \
    && find $PYENV_ROOT/versions/3.12*/* -name '__pycache__' | xargs rm -r

WORKDIR /home/$USER_NAME
RUN tar -cvzf pyenv.tar.gz .pyenv
