# Keycloak SPI BOM

![](https://img.shields.io/github/license/dasniko/keycloak-spi-bom?label=License)
[![Maven Central](https://img.shields.io/maven-central/v/com.github.dasniko/keycloak-spi-bom.svg?label=Maven%20Central)](https://central.sonatype.com/artifact/com.github.dasniko/keycloak-spi-bom)
![](https://img.shields.io/badge/Keycloak-26.5-blue)

## Why this BOM?

When developing custom SPIs (Service Provider Interfaces) and extensions for Keycloak, you need to compile against the same libraries that Keycloak itself ships with — at exactly the right versions.
A Maven BOM (Bill of Materials) is the standard way to manage this: import it once and all dependency versions are aligned automatically, with no manual version juggling across your `pom.xml`.

The official Keycloak SPI BOM is still lacking comprehensive dependency support — it covers only the core Keycloak artifacts, leaving developers to manually manage versions for commonly used libraries (utilities, testing, observability, etc.).
This BOM fills that gap by providing a curated, version-aligned set of managed dependencies for building Keycloak SPI extensions. It is the recommended way to manage Keycloak-related dependencies in your extension projects.

You are free to use this BOM _as-is_, so there's no warranty that everything is properly set.

## Versioning

Versioning is aligned to Keycloak **major and minor versions only** (no patch releases).
For example, BOM version `26.1` aligns with Keycloak `26.1.x`.
Just use the desired tag matching your target Keycloak version.

## Managed Dependencies

### Keycloak (scope: `provided`)

| Artifact | Description |
| --- | --- |
| `keycloak-core` | Core Keycloak classes |
| `keycloak-server-spi` | Public SPI interfaces |
| `keycloak-server-spi-private` | Internal SPI interfaces |
| `keycloak-services` | Service implementations |
| `keycloak-model-storage` | Storage model API |
| `keycloak-model-storage-private` | Storage model internals |
| `keycloak-model-storage-services` | Storage model services |
| `keycloak-model-infinispan` | Infinispan-based model |
| `keycloak-model-jpa` | JPA-based model |
| `keycloak-saml-core` | SAML core support |

### Runtime / Compile (scope: `provided`)

| Artifact | Description |
| --- | --- |
| `quarkus-rest` | Quarkus REST (JAX-RS) |
| `httpclient` (Apache) | HTTP client |
| `commons-lang3` | Apache Commons Lang |
| `commons-codec` | Apache Commons Codec |
| `commons-io` | Apache Commons IO |
| `guava` | Google Guava |
| `caffeine` | Caffeine cache |
| `micrometer-core` | Metrics / Micrometer |
| `lombok` | Lombok annotation processor |
| `auto-service` | Google Auto-Service |
| `slf4j-api` | SLF4J logging API |

### Testing (scope: `test`)

| Artifact | Description |
| --- | --- |
| `junit-jupiter` | JUnit 5 |
| `junit-jupiter-params` | JUnit 5 parameterized tests |
| `testcontainers-keycloak` | Keycloak Testcontainers (by @dasniko) |
| `testcontainers` JUnit 5 | Testcontainers JUnit 5 integration |
| `rest-assured` | REST API testing |
| `htmlunit` | Browser-based UI testing |
| `awaitility` | Async assertion support |
| `slf4j-reload4j` | SLF4J logging for tests |

## Usage

### Maven Central

Release versions are available on [Maven Central](https://central.sonatype.com/artifact/com.github.dasniko/keycloak-spi-bom).
Add the BOM to the `dependencyManagement` section of your `pom.xml`:

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.github.dasniko</groupId>
      <artifactId>keycloak-spi-bom</artifactId>
      <version>VERSION</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
    ...
  </dependencies>
</dependencyManagement>
```

For Gradle (Kotlin DSL):

```kotlin
dependencies {
    implementation(platform("com.github.dasniko:keycloak-spi-bom:VERSION"))
}
```

### Snapshot

There's also a `999.0.0-SNAPSHOT` version available, pointing to the latest Keycloak snapshot libraries.
To use it, add the snapshot repository to your `pom.xml`:

```xml
<repositories>
  <repository>
    <id>central-snapshots</id>
    <url>https://central.sonatype.com/repository/maven-snapshots/</url>
    <snapshots><enabled>true</enabled></snapshots>
  </repository>
</repositories>
```

## Contributing / Issues

Found a missing dependency or a version problem? Please open an issue or a pull request on [GitHub](https://github.com/dasniko/keycloak-spi-bom/issues).
