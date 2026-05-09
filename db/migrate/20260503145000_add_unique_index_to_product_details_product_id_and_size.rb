class AddUniqueIndexToProductDetailsProductIdAndSize < ActiveRecord::Migration[7.0]
  def up
    deduplicate_existing_sizes!

    execute <<~SQL
      CREATE UNIQUE INDEX index_product_details_on_product_id_and_normalized_size
      ON product_details (product_id, LOWER(BTRIM(size)));
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX IF EXISTS index_product_details_on_product_id_and_normalized_size;
    SQL
  end

  private

  def deduplicate_existing_sizes!
    duplicates = execute(<<~SQL)
      SELECT product_id, LOWER(BTRIM(size)) AS normalized_size
      FROM product_details
      WHERE size IS NOT NULL
      GROUP BY product_id, LOWER(BTRIM(size))
      HAVING COUNT(*) > 1
    SQL

    duplicates.each do |row|
      product_id = row['product_id']
      normalized_size = row['normalized_size']

      detail_ids = execute(<<~SQL).map { |record| record['id'] }
        SELECT id
        FROM product_details
        WHERE product_id = #{product_id}
          AND LOWER(BTRIM(size)) = #{quote(normalized_size)}
        ORDER BY id ASC
      SQL

      detail_ids.drop(1).each_with_index do |detail_id, index|
        execute <<~SQL
          UPDATE product_details
          SET size = CONCAT(BTRIM(size), ' (', #{index + 2}, ')')
          WHERE id = #{detail_id}
        SQL
      end
    end
  end
end
