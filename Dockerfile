############################################
#                                          #
# BUILD PHASE                              #
#                                          #
############################################
FROM postgres:9.6-bullseye

# installing maven
RUN apt update -y && apt -y install \
maven \
build-essential \
libelf1 \
libpopt0 \
librpm9 \
librpmbuild9 \
librpmio9 \
librpmsign9 \
rpm2cpio \
debugedit \
rpm-common \
wget

RUN wget http://ftp.it.debian.org/debian/pool/main/r/rpm/rpm_4.16.1.2+dfsg1-3_arm64.deb && dpkg -i rpm_4.16.1.2+dfsg1-3_arm64.deb

# creating the apt
COPY pom.xml /root
COPY src /root/src
COPY LICENSE AUTHORS /root/
RUN cd /root; ls -l src; mvn package

############################################
#                                          #
# EXEC PHASE                               #
#                                          #
############################################

# backend specific instructions
COPY --from=BUILDER /root/target/rpm/owb/RPMS/x86_64/owb-1.0.6-1.x86_64.rpm /root/
RUN yum -y install /root/owb-1.0.6-1.x86_64.rpm 

EXPOSE 80

# entrypoint
COPY src/scripts/entrypoint.sh /
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh" ]
