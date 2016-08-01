module OracleSchemaHelper
  def oracle_table_anchor(table)
    fail "Not a table: #{table.class}" unless table.is_a?(::Oracle::Dba::Table)
    content_tag(:a, '', name: table_anchor_name(table))
  end

  def oracle_table_link(table)
    fail "Not a table: #{table.class}" unless table.is_a?(::Oracle::Dba::Table)
    link_to table.to_s, '#' + table_anchor_name(table)
  end

  def oracle_constraint_anchor(constraint)
    content_tag(:a, '', name: constraint_anchor_name(constraint))
  end

  def oracle_constraint_link(constraint)
    link_to constraint.to_s, '#' + constraint_anchor_name(constraint)
  end

  private

  def constraint_anchor_name(constraint)
    "constraint_#{constraint.to_s.parameterize}"
  end

  def table_anchor_name(table)
    "table_#{table.to_s.parameterize}"
  end
end
