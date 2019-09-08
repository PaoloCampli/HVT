all: \
#    rcma_to_reg/output/rcma_to_reg.dta
	make_panel_rcma/output/make_panel_rcma.dta


# rcma_to_reg/output/rcma_to_reg.dta: \
# 	rcma_to_reg/input/make_panel_rcma.dta \
# 	rcma_to_reg/code/rcma_to_reg.do
#
# 	StataMP -b do rcma_to_reg/code/rcma_to_reg.do &


make_panel_rcma/output/make_panel_rcma.dta: \
	make_panel_rcma/input/clean_tax_bases.dta \
#	make_panel_rcma/input/mkt_access_byorigin*.dta \
#	make_panel_rcma/input/fake/mkt_access_byorigin*.dta \
#	make_panel_rcma/code/make_panel_rcma.do

	StataMP -b do make_panel_rcma/code/make_panel_rcma.do &
