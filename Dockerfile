FROM gentoo/stage3:nomultilib as builder

RUN emerge-webrsync \
  && rmdir /etc/portage/{package.use,package.accept_keywords} \
  && sed -i 's/^COMMON_FLAGS.*/COMMON_FLAGS="-O2 -march=native -pipe"/' /etc/portage/make.conf \
  && echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >> /etc/portage/make.conf \
  && echo "MAKEOPTS=\"-j$(nproc)\"" >> /etc/portage/make.conf \
  && emerge -1q app-portage/cpuid2cpuflags \
  && echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use \
  && echo "*/* -nls -iconv -man -doc -gtk-doc" >> /etc/portage/package.use

RUN emerge -qDNu --backtrack=100 @world

RUN  emerge -c \
  && rm -rf /var/cache/distfiles/*

FROM scratch

WORKDIR /
COPY --from=builder / /

CMD [ "/bin/bash", "--login" ]
ENTRYPOINT [ "/bin/bash", "--login", "-c" ]
