#
# Dockerfile for https://github.com/LASAGNE-Open-Systems/LASAGNE-Core
#

FROM ubuntu:17.04

# Update package repositories and install build-essential

RUN apt-get update && apt-get install -y build-essential git figlet

# clone LASAGNE-Core and dependencies

RUN git clone --depth 1 git://github.com/DOCGroup/MPC.git /opt/MPC \
 && git clone -b Latest_Micro --depth 1 git://github.com/DOCGroup/ACE_TAO.git /opt/ACE_TAO \
 && git clone --depth 1 git://github.com/objectcomputing/OpenDDS.git /opt/OpenDDS \
 && git clone --depth 1 git://github.com/LASAGNE-Open-Systems/LASAGNE-Core.git /opt/LASAGNE-Core

# Setup environment variables

ENV MPC_ROOT=/opt/MPC \
    ACE_ROOT=/opt/ACE_TAO/ACE \
    TAO_ROOT=/opt/ACE_TAO/TAO \
    DDS_ROOT=/opt/OpenDDS \
    DAF_ROOT=/opt/LASAGNE-Core

ENV TAF_ROOT=$DAF_ROOT/TAF \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ACE_ROOT/lib:$DDS_ROOT/lib:$DAF_ROOT/lib

# build LASAGNE-Core

WORKDIR $TAF_ROOT

RUN cp $DAF_ROOT/bin/build/ace/config.h $ACE_ROOT/ace/config.h \
 && cp $DAF_ROOT/bin/build/ace/default.features $ACE_ROOT/bin/MakeProjectCreator/config/default.features \
 && cp $DAF_ROOT/bin/build/ace/platform_macros.GNU $ACE_ROOT/include/makeinclude/platform_macros.GNU \
 && perl $ACE_ROOT/bin/mwc.pl -type gnuace -workers 2 TAF_CI.mwc \
 && make --jobs 2

# copy TextParser script and execute it

WORKDIR $DAF_ROOT/bin

ADD TextParser.sh $DAF_ROOT/bin

CMD $DAF_ROOT/bin/TextParser.sh
