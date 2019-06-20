resource "aws_waf_ipset" "ipset" {
  name = "AllowMyIPGlobalSet"

  ip_set_descriptors {
    type  = "IPV4"
    value = "${var.webacl_allow_ip_address}/32"
  }
}

resource "aws_waf_rule" "wafrule" {
  name        = "AllowMyIPGlobalWAFRule"
  metric_name = "AllowMyIPGlobalWAFRule"

  predicates {
    data_id = "${aws_waf_ipset.ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "wafacl" {
  name        = "AllowMyIPGlobalWebACL"
  metric_name = "AllowMyIPGlobalWebACL"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_waf_rule.wafrule.id}"
    type     = "REGULAR"
  }
}
