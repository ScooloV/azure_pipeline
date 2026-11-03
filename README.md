# azure_pipeline

A minimal C++ example for trying Azure Pipelines.

`main.cpp` prints `Hello, world!`. The `azure-pipelines.yml` pipeline:

1. Runs on pushes to `main` or when started manually.
2. Logs the OS, CPU, memory, disk space, tool versions, agent details, branch,
   and commit. It does not dump all environment variables.
3. Compiles the program with `g++` using C++17.
4. Runs the program and checks its output; an error fails the build.
5. Publishes the Linux executable as the `hello-world-linux` artifact.

## Run in Azure DevOps

1. Push these files to your repository.
2. Open **Pipelines → New pipeline** and select the source and repository.
3. Select **Existing Azure Pipelines YAML file** and `/azure-pipelines.yml`.
4. Click **Run**. View logs in the job steps and download the executable from **Artifacts**.

The pipeline uses the Microsoft-hosted `ubuntu-latest` agent. Your organization
must have a Microsoft-hosted parallel job available.

## Build locally (Linux / WSL with g++ installed)

```bash
mkdir -p build
g++ -std=c++17 -O2 -Wall -Wextra -Werror -pedantic main.cpp -o build/hello-world
./build/hello-world
```

Documentation: [Azure Pipelines jobs](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/phases?view=azure-devops&tabs=yaml)
and [pipeline artifacts](https://learn.microsoft.com/en-us/azure/devops/pipelines/artifacts/pipeline-artifacts?view=azure-devops&tabs=yaml).
