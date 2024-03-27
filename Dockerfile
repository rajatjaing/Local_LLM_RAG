# syntax=docker/dockerfile:1
# Build as `docker build . -t localgpt`, requires BuildKit.
# Run as `docker run -it --mount src="$HOME/.cache",target=/root/.cache,type=bind --gpus=all localgpt`, requires Nvidia container toolkit.

FROM nvidia/cuda:11.7.1-runtime-ubuntu22.04
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-get install -y g++-11 make python3 python-is-python3 pip
RUN mkdir /root/ask-local-gpt/
COPY ./requirements.txt /root/ask-local-gpt/
# use BuildKit cache mount to drastically reduce redownloading from pip on repeated builds
#RUN --mount=type=cache,target=/root/.cache CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install --timeout 100 -r requirements.txt llama-cpp-python==0.1.83
RUN CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install --timeout 100 -r /root/ask-ncc/requirements.txt llama-cpp-python==0.1.83
COPY SOURCE_DOCUMENTS /root/ask-local-gpt/SOURCE_DOCUMENTS/
COPY embedding_model/ /root/ask-local-gpt/embedding_model/
COPY llm_model/ /root/ask-local-gpt/llm_model/
COPY ingest.py constants.py utils.py prompt_template_utils.py /root/ask-local-gpt/
# Docker BuildKit does not support GPU during *docker build* time right now, only during *docker run*.
# See <https://github.com/moby/buildkit/issues/1436>.
# If this changes in the future you can `docker build --build-arg device_type=cuda  . -t localgpt` (+GPU argument to be determined).
ARG device_type=cpu
#RUN --mount=type=cache,target=/root/.cache python ingest.py --device_type $device_type
RUN python /root/ask-local-gpt/store_embed.py --device_type $device_type
COPY . /root/ask-local-gpt/
ENV device_type=cpu
CMD python /root/ask-local-gpt/run_app.py --device_type $device_type
