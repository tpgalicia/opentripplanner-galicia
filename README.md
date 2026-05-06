# OpenTripPlanner para Galicia

Este repositorio contiene un sistema de configuración de OpenTripPlanner (OTP) adaptado para la región de Galicia, España. OTP es una plataforma de planificación de rutas multimodales que permite a los usuarios encontrar las mejores rutas utilizando diferentes medios de transporte, como caminar, bicicleta, transporte público y automóvil.

Este repositorio incluye:

- Tareas de descarga automáticas:
  - OpenTripPlanner: Descarga de la última versión estable en JAR
  - GeoFabrik: Datos de OpenStreetMap para Galicia
  - GTFS: Transporte Público de Galicia (interurbanos, y urbanos de Ferrol y Pontevedra)
  - GTFS: Renfe (General, FEVE y Cercanías)
  - GTFS: Urbano de A Coruña
  - GTFS: Urbano de Ourense
  - GTFS: Urbano de Vigo
- Feeds "de la comunidad":
  - GTFS: Santiago de Compostela (WIP)
  - GTFS: Ourense (WIP)
  - GTFS: Lugo
- Proxy del GTFS RealTime de Renfe para integración con OTP
- Configuración de OpenTripPlanner para cargar los datos descargados y el tiempo real de Renfe
- Tareas para ejecutar OTP directamente

## Instalación y uso

Para ejecutar los contenidos de este repositorio, es necesario tener descargado:

- **Java 25 LTS**: en sistemas Windows o macOS, se recomienda descargar de [Adoptium](https://adoptium.net/). En sistemas Linux, se puede instalar OpenJDK 25 desde los repositorios oficiales.
- **Just**: Se recomienda tener [Just](https://just.systems/) instalado para gestionar las tareas definidas en el [`justfile`](./justfile). Alternativamente, se pueden ejecutar directamente, pero es más sencillo con Just.
- **Rancher, Docker o Podman**: Para generar los `shapes` de Renfe, se necesita tener dos instancias de OSRM: una para las líneas de ancho ibérico/internacional, y otra para ancho métrico (antiguo FEVE). Se facilita en `build_renfe` un fichero compose.yaml con un Dockerfile para generar el contenedor personalizado y ejecutar los servidores en los puertos 5000 y 5001, con `cd build_renfe` y `nerdctl compose up -d`.
- **Python y `uv`**: Para los parches sobre algunos feeds, es necesario tener Python, `requests` y otros paquetes instalados. Utilizando [`uv`](https://docs.astral.sh/uv) se puede ejecutar todo con solo una línea. El justfile asume que se está utilizando `uv` directamente.
- **Clave de API del NAP del Ministerio de Transportes**: Para poder descargar los feeds disponibles en el Punto de Acceso Nacional (NAP), es necesario registrarse y obtener una clave de API en [https://nap.transportes.gob.es/](https://nap.transportes.gob.es/).

Para descargar los datos y ejecutar OTP, se pueden utilizar las siguientes tareas:

```bash
git clone https://github.com/tpgalicia/opentripplanner-galicia.git
cd opentripplanner-galicia
just setup **clave_api_nap**
just build
```

Iniciar OpenTripPlanner (asumiento que se ejecutaron los pasos anteriores y ya se cuenta con el `graph.obj`):

```bash
just serve
```

## Licencia

Este proyecto está cedido como software libre bajo licencia EUPL v1.2 o superior. Más información en el archivo [`LICENCE`](./LICENCE) o en [Interoperable Europe](https://interoperable-europe.ec.europa.eu/collection/eupl).

Los datos GTFS originales están cedidos por sus propietarios bajo sus respectivas licencias, aunque siempre bajo licencias abiertas y gratuitas. Al no distribuir directamente los datos, sino scripts para descargarlos, entendemos que no es necesario incluir las licencias de los datos directamente en este repositorio, quedando a criterio del usuario final el cumplimiento de las mismas.
