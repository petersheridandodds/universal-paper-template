zip \
    -FS \
    --exclude=make-zip-file* \
    --exclude=*.zip \
    `basename $PWD`-overleaf.zip \
    * \
    correspondence/* \
    correspondence/figures/* \
    figures/localized/* \
    inputs/localized/*
