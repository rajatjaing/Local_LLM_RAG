## Pre-Requisites 
- Before creating image, we need to create a folder llm_model and embedding_model.
- In llm_model folder put the model file like .gguf, pythorch.bin, tensorflow.bin, .ggml, .gptq etc. for example --> downlaod codellama-7b.Q3_K_M.gguf from TheBloke/CodeLlama-7B-GGUF --> https://huggingface.co/TheBloke/CodeLlama-7B-GGUF/resolve/main/codellama-7b.Q3_K_M.gguf?download=true
- In embedding_model folder, put the embedding model file. for example --> git clone https://huggingface.co/sentence-transformers/all-mpnet-base-v2

## Technical Details 🛠️
By selecting the right local models and the power of `LangChain` you can run the entire RAG pipeline locally, without any data leaving your environment, and with reasonable performance.

- `store_embed.py` uses `LangChain` tools to parse the document and create embeddings locally using `Embeddings`. It then stores the result in a local vector database using `Chroma` vector store.
- `run_app.py` uses a local LLM to understand questions and create answers. The context for the answers is extracted from the local vector store using a similarity search to locate the right piece of context from the docs.
- You can replace this local LLM with any other LLM from the HuggingFace. Make sure whatever LLM you select is in the HF format.

This project was inspired by the original [privateGPT](https://github.com/imartinez/privateGPT).

## Built Using 🧩
- [LangChain](https://github.com/hwchase17/langchain)
- [HuggingFace LLMs](https://huggingface.co/models)
- [LLAMACPP](https://github.com/abetlen/llama-cpp-python)
- [ChromaDB](https://www.trychroma.com/)
- [Streamlit](https://streamlit.io/)

## Ingesting your OWN Data.
Put your files in the `SOURCE_DOCUMENTS` folder. You can put multiple folders within the `SOURCE_DOCUMENTS` folder and the code will recursively read your files.

### Support file formats:
LocalGPT currently supports the following file formats. LocalGPT uses `LangChain` for loading these file formats. The code in `constants.py` uses a `DOCUMENT_MAP` dictionary to map a file format to the corresponding loader. In order to add support for another file format, simply add this dictionary with the file format and the corresponding loader from [LangChain](https://python.langchain.com/docs/modules/data_connection/document_loaders/).

```shell
DOCUMENT_MAP = {
    ".txt": TextLoader,
    ".md": TextLoader,
    ".py": TextLoader,
    ".java": TextLoader,
    ".pdf": PDFMinerLoader,
    ".csv": CSVLoader,
    ".xls": UnstructuredExcelLoader,
    ".xlsx": UnstructuredExcelLoader,
    ".docx": Docx2txtLoader,
    ".doc": Docx2txtLoader,
}
```

python store_embed.py
```
Use the device type argument to specify a given device.
To run on `cpu`

```sh
python store_embed.py --device_type cpu
```

To run on `M1/M2`

```sh
python store_embed.py --device_type mps
```

Use help for a full list of supported devices.

```sh
python store_embed.py --help
```

This will create a new folder called `DB` and use it for the newly created vector store. You can ingest as many documents as you want, and all will be accumulated in the local embeddings database.
If you want to start from an empty database, delete the `DB` and reingest your documents.

Note: When you run this for the first time, it will need internet access to download the embedding model (default: `Instructor Embedding`). In the subsequent runs, no data will leave your local environment and you can ingest data without internet connection.

## Ask questions to your documents, locally!

In order to chat with your documents, run the following command (by default, it will run on `cuda`).

```shell
python run_app.py
```
You can also specify the device type just like `store_embed.py`

```shell
python run_app.py --device_type mps # to run on Apple silicon
```

This will load the ingested vector store and embedding model. You will be presented with a prompt:

```shell
> Enter a query:
```

After typing your question, hit enter. local-llm-rag will take some time based on your hardware.

Once the answer is generated, you can then ask another question without re-running the script, just wait for the prompt again.


Type `exit` to finish the script.

### Extra Options with run_app.py

You can use the `--show_sources` flag with `run_app.py` to show which chunks were retrieved by the embedding model. By default, it will show 4 different sources/chunks. You can change the number of sources/chunks

```shell
python run_app.py --show_sources
```

Another option is to enable chat history. ***Note***: This is disabled by default and can be enabled by using the  `--use_history` flag. The context window is limited so keep in mind enabling history will use it and might overflow.

```shell
python run_app.py --use_history
```

You can store user questions and model responses with flag `--save_qa` into a csv file `/local_chat_history/qa_log.csv`. Every interaction will be stored. 

```shell
python run_app.py --save_qa
```

# GPU and VRAM Requirements

Below is the VRAM requirement for different models depending on their size (Billions of parameters). The estimates in the table does not include VRAM used by the Embedding models - which use an additional 2GB-7GB of VRAM depending on the model.

| Mode Size (B) | float32   | float16   | GPTQ 8bit      | GPTQ 4bit          |
| ------- | --------- | --------- | -------------- | ------------------ |
| 7B      | 28 GB     | 14 GB     | 7 GB - 9 GB    | 3.5 GB - 5 GB      |
| 13B     | 52 GB     | 26 GB     | 13 GB - 15 GB  | 6.5 GB - 8 GB      |
| 32B     | 130 GB    | 65 GB     | 32.5 GB - 35 GB| 16.25 GB - 19 GB   |
| 65B     | 260.8 GB  | 130.4 GB  | 65.2 GB - 67 GB| 32.6 GB - 35 GB    |


# System Requirements

## Python Version

To use this software, you must have Python 3.10 or later installed. Earlier versions of Python will not compile.
