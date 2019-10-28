CHISEL_VERSION = 1.3.2
org = thenatureofsoftware
chisel-img = chisel
chisel-tag = $(CHISEL_VERSION)
chisel-opts-arm = --build-arg VERSION=$(CHISEL_VERSION) --build-arg OPTS="GOARCH=arm GOARM=7" --platform linux/arm/v7
chisel-opts-arm64 = --build-arg VERSION=$(CHISEL_VERSION) --build-arg OPTS="GOARCH=arm64" --platform linux/arm64
chisel-opts-amd64 = --build-arg VERSION=$(CHISEL_VERSION) --build-arg OPTS="GOARCH=amd64" --platform linux/amd64

.PHONY:
all: clean chisel-manifest

chisel-images: out/images/$(chisel-img)-linux-arm.tgz out/images/$(chisel-img)-linux-arm64.tgz out/images/$(chisel-img)-linux-amd64.tgz

out/images/chisel-linux-%.tgz:
	@mkdir -p $$(dirname $@_)
	docker buildx build $(chisel-opts-$*) -t $(org)/$(chisel-img)-$*:$(chisel-tag) images/chisel
	docker save $(org)/$(chisel-img)-$*:$(chisel-tag) | gzip -c > out/images/chisel-linux-$*.tgz

chisel-manifest: chisel-images
	docker push $(org)/$(chisel-img)-arm:$(chisel-tag)
	docker push $(org)/$(chisel-img)-arm64:$(chisel-tag)
	docker push $(org)/$(chisel-img)-amd64:$(chisel-tag)

	docker manifest create --amend $(org)/$(chisel-img):$(chisel-tag) \
    		$(org)/$(chisel-img)-arm:$(chisel-tag) \
    		$(org)/$(chisel-img)-arm64:$(chisel-tag) \
    		$(org)/$(chisel-img)-amd64:$(chisel-tag)

	docker manifest annotate $(org)/$(chisel-img):$(chisel-tag) $(org)/$(chisel-img)-arm:$(chisel-tag) --os linux --arch arm --variant v7
	docker manifest annotate $(org)/$(chisel-img):$(chisel-tag) $(org)/$(chisel-img)-arm64:$(chisel-tag) --os linux --arch arm64
	docker manifest annotate $(org)/$(chisel-img):$(chisel-tag) $(org)/$(chisel-img)-amd64:$(chisel-tag) --os linux --arch amd64

	docker manifest push $(org)/$(chisel-img):$(chisel-tag)

clean:
	rm -rf out
