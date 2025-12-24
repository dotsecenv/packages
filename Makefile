.PHONY: cleanup-dry-run
cleanup-dry-run:
	@./.github/cleanup-old-packages.sh

.PHONY: clean
clean:
	@./.github/cleanup-old-packages.sh --force

.PHONY: publish-packages
publish-packages:
	@echo "Publish https://get.dotsecenv.com/ from latest commit..."
	@gh workflow run publish.yml --ref main
