FROM gentoo/stage3 as builder

RUN emerge-webrsync \
  && echo '-*virtual/ssh'        >  /etc/portage/profile/packages \
  && echo '-*virtual/editor'     >> /etc/portage/profile/packages \
  && echo '-*net-misc/rsync'     >> /etc/portage/profile/packages \
  && echo '-*virtual/pager'      >> /etc/portage/profile/packages \
  && echo '-*sys-apps/less'      >> /etc/portage/profile/packages \
  && echo '-*virtual/man'        >> /etc/portage/profile/packages \
  && echo '-*sys-apps/man-pages' >> /etc/portage/profile/packages \
  && echo '-*sys-fs/e2fsprogs'   >> /etc/portage/profile/packages \
  && echo '-*sys-apps/kbd'       >> /etc/portage/profile/packages \
  && echo '-*sys-apps/kmod'      >> /etc/portage/profile/packages \
  && rmdir /etc/portage/{package.use,package.accept_keywords} \
  && sed -i 's/^COMMON_FLAGS.*/COMMON_FLAGS="-O2 -march=native -pipe"/' /etc/portage/make.conf \
  && echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >> /etc/portage/make.conf \
  && echo "MAKEOPTS=\"-j$(nproc)\"" >> /etc/portage/make.conf \
  && eselect profile set default/linux/amd64/17.1/no-multilib \
  && emerge -1q app-portage/cpuid2cpuflags \
  && echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use \
  && echo "*/* -nls -iconv -man -doc -gtk-doc" >> /etc/portage/package.use \
  && emerge -c

RUN emerge -eq @world \
  && emerge -c \
  && rm -rf /var/cache/distfiles/* /var/db/repos/*

FROM scratch

WORKDIR /
COPY --from=builder / /

CMD [ "/bin/bash", "--login" ]
ENTRYPOINT [ "/bin/bash", "--login", "-c" ]
