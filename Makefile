.PHONY: cleanup-dry-run
cleanup-dry-run:
	@./.github/cleanup-old-packages.sh

.PHONY: clean
clean:
	@./.github/cleanup-old-packages.sh --force
