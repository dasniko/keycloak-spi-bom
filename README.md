# (Custom) Keycloak SPI BOM

![](https://img.shields.io/github/license/dasniko/keycloak-spi-bom?label=License)
[![Maven Central](https://img.shields.io/maven-central/v/com.github.dasniko/keycloak-spi-bom.svg?label=Maven%20Central)](https://search.maven.org/search?q=g:%22com.github.dasniko%22%20AND%20a:%22keycloak-spi-bom%22)
![](https://img.shields.io/badge/Keycloak-26.2-blue)

As the official Keycloak SPI BOM is still lacking good and comprehensive dependency support, I maintain an own, custom Keycloak SPI BOM to use in Keycloak SPI extension projects.

You are free to use this BOM _as-is_, so there's no warranty that everything is properly set.
Versioning is aligned to Keycloak versions, but only major and minor versions, no patch releases!
Just use the desired proper tag.

## Usage

### Maven Central

The release versions beginning of `19.0.0` of this project are available at [Maven Central](https://search.maven.org/artifact/com.github.dasniko/keycloak-spi-bom).
Simply put the dependency coordinates to the `dependencyManagement` section in your `pom.xml` (or something similar, if you use e.g. Gradle or something else):

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
