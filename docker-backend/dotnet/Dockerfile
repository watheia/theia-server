FROM registry.digitalocean.com/watheia/theia-server:common

# .NET Core SDK
ARG DOTNET_VERSION=3.1
# Disables .NET telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
# Suppresses .NET welcome message
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1

RUN curl -SLO "https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-$DOTNET_VERSION
