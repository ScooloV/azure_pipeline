# azure_pipeline

A minimal C++ example that builds source downloaded from Azure Artifacts.
All comments and pipeline messages are in English.

## How it works

1. Create a ZIP containing `main.cpp` at its root.
2. Publish a folder containing that ZIP as a Universal Package to Azure Artifacts.
3. Start the pipeline manually, or push to `main`.
4. The pipeline logs OS, CPU, memory, disk, tools, and Azure agent details.
5. It downloads the Universal Package and extracts `main.cpp` from its ZIP.
6. It compiles the downloaded source with `g++` using C++17, runs it, and checks
   that the output is `Hello, world!`.
7. It publishes the Linux executable as the `hello-world-linux` pipeline artifact.

The build uses `build/source/main.cpp` from the downloaded ZIP. Source changes
in the repository take effect after you publish a new package version and update
`sourceVersion` in `azure-pipelines.yml`.

## Azure CLI setup (PowerShell)

### Portable installation without administrator rights

Azure CLI is installed under `C:\Projects\azure-cli`, and
`C:\Projects\azure-cli\bin` is added to the Windows user PATH.
Restart VS Code after installation so its terminals inherit the updated PATH:

```powershell
az version
```

To use it immediately in an existing PowerShell terminal:

```powershell
$env:Path = "C:\Projects\azure-cli\bin;$env:Path"
```

The installation is outside the repository and survives deletion of `build`.
It does not modify the system PATH or require administrator rights.

For an alternative installation inside another checkout (current terminal only):

```powershell
New-Item -ItemType Directory -Force build/tools/azure-cli | Out-Null
curl.exe --fail --location --output build/tools/azure-cli.zip https://aka.ms/installazurecliwindowszipx64
if ($LASTEXITCODE -ne 0) { throw 'Azure CLI download failed.' }
tar.exe -xf build/tools/azure-cli.zip -C build/tools/azure-cli
if ($LASTEXITCODE -ne 0) { throw 'Azure CLI extraction failed.' }
$env:Path = "$(Get-Location)\build\tools\azure-cli\bin;$env:Path"
```

### Standard installation

Install Azure CLI if `az` is not available, then reopen your terminal:

```powershell
winget install --exact --id Microsoft.AzureCLI
```

### Extension and authentication

Install the Azure DevOps extension and sign in with your organization account:

```powershell
az extension add --name azure-devops
az login --allow-no-subscriptions
```

If the extension is already installed, use `az extension update --name azure-devops`.
Azure DevOps Artifacts does not require an Azure subscription. The
`--allow-no-subscriptions` option allows sign-in when your account has tenant
access but no accessible Azure subscriptions.
If your organization requires PAT authentication, use
`az devops login --organization https://dev.azure.com/Wacker-Neuson/` and enter
an appropriate PAT at the prompt. Do not commit credentials to the repository.

## Create and publish the source archive (PowerShell)

Run these commands from the repository root. Use a dedicated folder so that only
the ZIP is included in the package, rather than the entire repository or build output:

```powershell
New-Item -ItemType Directory -Force build/package | Out-Null
Compress-Archive -Path main.cpp -DestinationPath build/package/hello-world-source.zip -Force

az artifacts universal publish `
    --organization 'https://dev.azure.com/Wacker-Neuson/' `
    --project 'ccse-hmi-dev' `
    --scope project `
    --feed 'azure_pipeline' `
    --name 'hello-world-source' `
    --version '1.0.0' `
    --description 'C++ Hello World source archive' `
    --path 'build/package'
```

The publishing account needs Feed Publisher (Contributor) permission on the feed.
After publishing, `hello-world-source` version `1.0.0` should appear under
**Artifacts > azure_pipeline**. The package contains `hello-world-source.zip`,
which contains `main.cpp` at its root.

Package versions are immutable. For a source update, publish a new version such
as `1.0.1` and update `sourceVersion` in the YAML to match. Uploading a package
does not automatically trigger this pipeline.

## Configure and run Azure Pipelines

1. Push the repository files to Azure DevOps organization `Wacker-Neuson`.
2. Open **Pipelines > New pipeline** and select the repository.
3. Select **Existing Azure Pipelines YAML file** and `/azure-pipelines.yml`.
4. Confirm these YAML variables match the published package:

   | Variable | Value |
   | --- | --- |
   | `sourceFeed` | `ccse-hmi-dev/azure_pipeline` |
   | `sourcePackage` | `hello-world-source` |
   | `sourceVersion` | `1.0.0` |

5. In **Artifacts > azure_pipeline > Feed settings > Permissions**, ensure the
   pipeline's Build Service identity has at least Feed Reader permission.
   For a pipeline in this project, this is typically
   `ccse-hmi-dev Build Service (Wacker-Neuson)`. For a pipeline in another project,
   grant its Build Service access to the feed and the project hosting it.
6. Save and run. View logs in the job steps and download the executable from **Artifacts**.

`UniversalPackages@0` uses the build identity for a feed in the same organization.
No Artifactory URL or token is needed; remove the old `ARTIFACTORY_ARCHIVE_URL`
and `ARTIFACTORY_TOKEN` pipeline variables if you previously added them.

The pipeline uses the Microsoft-hosted `ubuntu-latest` agent. Your organization
must have a Microsoft-hosted parallel job available.

## Build locally (Linux / WSL with g++ installed)

```bash
mkdir -p build
g++ -std=c++17 -O2 -Wall -Wextra -Werror -pedantic main.cpp -o build/hello-world
./build/hello-world
```

Documentation: [publish Universal Packages](https://learn.microsoft.com/en-us/azure/devops/artifacts/quickstarts/publish-universal-packages?view=azure-devops),
[Universal Packages pipeline task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/universal-packages-v0?view=azure-pipelines),
and [pipeline artifacts](https://learn.microsoft.com/en-us/azure/devops/pipelines/artifacts/pipeline-artifacts?view=azure-devops&tabs=yaml).
