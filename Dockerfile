FROM registry.svc.ci.openshift.org/openshift/release:golang-1.13 AS builder
WORKDIR /go/src/github.com/openshift/cluster-samples-operator
COPY . .
RUN make build

FROM registry.svc.ci.openshift.org/origin/4.6:base
COPY --from=builder /go/src/github.com/openshift/cluster-samples-operator/cluster-samples-operator /usr/bin/
RUN ln -f /usr/bin/cluster-samples-operator /usr/bin/cluster-samples-operator-watch
COPY manifests/image-references manifests/0* /manifests/
COPY vendor/github.com/openshift/api/samples/v1/0000_10_samplesconfig.crd.yaml /manifests/
# For OCP:
# COPY assets/operator/ocp-x86_64 /opt/openshift/operator/x86_64
# COPY assets/operator/ocp-s390x /opt/openshift/operator/s390x
# COPY assets/operator/ocp-ppc64le /opt/openshift/operator/ppc64le
COPY assets/operator/okd-x86_64 /opt/openshift/operator/x86_64
RUN useradd cluster-samples-operator
USER cluster-samples-operator
ENTRYPOINT []
CMD ["/usr/bin/cluster-samples-operator"]
LABEL io.openshift.release.operator true
