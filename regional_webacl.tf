resource "aws_wafregional_ipset" "ipset" {
  name = "AllowMyIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = "${var.webacl_allow_ip_address}/32"
  }
}

resource "aws_wafregional_rule" "wafrule" {
  name        = "AllowMyIPWAFRule"
  metric_name = "AllowMyIPWAFRule"

  predicate {
    data_id = "${aws_wafregional_ipset.ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "wafacl" {
  name        = "AllowMyIPWebACL"
  metric_name = "AllowMyIPWebACL"

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_wafregional_rule.wafrule.id}"
    type     = "REGULAR"
  }
}
