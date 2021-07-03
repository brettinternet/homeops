"""
*This is a WIP*

A diagram as code for my homelab.

`Diagram` documentation: https://diagrams.mingrammer.com/docs/guides/diagram
"""

from diagrams import Cluster, Diagram, Edge, Node
from diagrams.onprem.iac import Ansible, Terraform
from diagrams.generic.network import Firewall
from diagrams.onprem.compute import Server
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.onprem.network import Traefik
from diagrams.saas.cdn import Cloudflare
from diagrams.generic.compute import Rack
from diagrams.onprem.certificates import LetsEncrypt

# https://github.com/mingrammer/diagrams/issues/447#issuecomment-770430158
# https://graphviz.gitlab.io/doc/info/shapes.html#html
legend_text = """<
    <U>Legend</U> <BR ALIGN="LEFT" /><BR/>
    <FONT color="gray">●</FONT> automated <BR ALIGN="LEFT" />
    <FONT color="green">●</FONT> proxy <BR ALIGN="LEFT" />
    >"""

with Diagram("Homelab", show=False, outformat="png"):
    Node(
        label=legend_text,
        width="4",
        shape="plaintext",
    )

    workstation = Ansible("homelab.git")

    with Cluster("Service Node"):
        ingress = Traefik("ingress")
        middleware = [Firewall("OAuth middlware")]
        ingress >> Edge(style="dashed") >> middleware

        (
            ingress
            >> Edge(color="green")
            >> [
                Server("adguard"),
                Server("espial"),
                Server("miniflux"),
                PostgreSQL("miniflux_db"),
                Server("firefly"),
                PostgreSQL("firefly_db"),
                Server("healthchecks"),
                Server("n8n"),
                PostgreSQL("n8n_db"),
                Prometheus("prometheus"),
                Grafana("grafana"),
                Firewall("oauth"),
            ]
        )

    with Cluster("Media Node"):
        media_services = [
            Server("plex"),
            Server("ombi"),
            Server("calibre"),
            Server("calibre-web"),
            Server("nzbget"),
            Server("radarr"),
            Server("sonarr"),
            Server("lazylibrarian"),
            Server("tautulli"),
        ]
        ingress >> Edge(color="green") >> media_services

    (
        ingress
        >> Edge(color="gray", style="dashed")
        >> LetsEncrypt("LetsEncrypt")
        >> Edge(color="gray", style="dashed")
        >> ingress
    )
    bastionDroplet = Terraform("DigitalOcean")
    Cloudflare("proxy") - Edge(color="gray") - ingress
    workstation >> Edge(color="blue", style="dashed") >> ingress
    workstation >> Edge(color="blue", style="dashed") >> bastionDroplet
    bastionDroplet >> Edge(color="blue", style="dashed") >> Rack("bastion")
