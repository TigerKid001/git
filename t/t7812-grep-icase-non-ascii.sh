#!/bin/sh

test_description='grep icase on non-English locales'

. ./lib-gettext.sh

test_expect_success GETTEXT_LOCALE 'setup' '
	printf "TILRAUN: Halló Heimur!" >file &&
	git add file &&
	LC_ALL="$is_IS_locale" &&
	export LC_ALL
'

test_have_prereq GETTEXT_LOCALE &&
test-regex "HALLÓ" "Halló" ICASE &&
test_set_prereq REGEX_LOCALE

test_expect_success REGEX_LOCALE 'grep literal string, no -F' '
	git grep -i "TILRAUN: Halló Heimur!" &&
	git grep -i "TILRAUN: HALLÓ HEIMUR!"
'

test_expect_success REGEX_LOCALE 'grep literal string, with -F' '
	git grep --debug -i -F "TILRAUN: Halló Heimur!"  2>&1 >/dev/null |
		 grep fixed >debug1 &&
	echo "fixed TILRAUN: Halló Heimur!" >expect1 &&
	test_cmp expect1 debug1 &&

	git grep --debug -i -F "TILRAUN: HALLÓ HEIMUR!"  2>&1 >/dev/null |
		 grep fixed >debug2 &&
	echo "fixed TILRAUN: HALLÓ HEIMUR!" >expect2 &&
	test_cmp expect2 debug2
'

test_expect_success REGEX_LOCALE 'grep string with regex, with -F' '
	printf "^*TILR^AUN:.* \\Halló \$He[]imur!\$" >file &&

	git grep --debug -i -F "^*TILR^AUN:.* \\Halló \$He[]imur!\$" 2>&1 >/dev/null |
		 grep fixed >debug1 &&
	echo "fixed \\^*TILR^AUN:\\.\\* \\\\Halló \$He\\[]imur!\\\$" >expect1 &&
	test_cmp expect1 debug1 &&

	git grep --debug -i -F "^*TILR^AUN:.* \\HALLÓ \$HE[]IMUR!\$"  2>&1 >/dev/null |
		 grep fixed >debug2 &&
	echo "fixed \\^*TILR^AUN:\\.\\* \\\\HALLÓ \$HE\\[]IMUR!\\\$" >expect2 &&
	test_cmp expect2 debug2
'

test_done
