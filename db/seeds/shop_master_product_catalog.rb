# Product rows transcribed from shop_master_product_catalog.csv, which is the
# normalized source data from Shop_Master_Product_Catalog.xlsx.
require 'csv'
require 'bigdecimal'

CATALOG_CATEGORY_DESCRIPTIONS = {
  'Deodorant' => 'Deodorant and fragrance products from the supplier catalog. Follow each package label for exact product type and instructions.',
  'Glycerine' => 'Glycerine and related personal-care products. Ingredients and intended use vary by item; check the package label.',
  'Concentré' => 'Concentrated skin-care products from the supplier catalog. Product-specific ingredients and directions were not supplied.',
  'Lotion' => 'Skin-care lotions listed in the supplier catalog. Check each package label for ingredients and directions.',
  'Tube (Crème)' => 'Creams and topical products sold in tubes, as categorized by the supplier. Check the label for ingredients and intended use.',
  'Serum' => 'Skin-care serums listed by the supplier. Product-specific ingredients and directions were not supplied.',
  'Anti-Spot' => 'Products categorized as anti-spot by the supplier. No ingredient or efficacy claims are inferred.',
  'Body Oil (Mafuta)' => 'Body and skin oils from the supplier catalog. Check each package label for ingredients and directions.'
}.freeze

CATALOG_SOURCE_CATEGORY_MAP = {
  'Deodorant' => 'Deodorant',
  'Glycerine' => 'Glycerine',
  'Concentré' => 'Concentré',
  'Body Oil (Mafuta)' => 'Body Oil (Mafuta)'
}.freeze

CATALOG_ITEMS = CSV.foreach(File.join(__dir__, 'shop_master_product_catalog.csv'), headers: true).map do |row|
  source_category = row.fetch('source_category')
  category = CATALOG_SOURCE_CATEGORY_MAP[source_category]
  if source_category == 'Lotion, Tube, Serum, Spot'
    category = row.fetch('notes', '').to_s[/Category:\s*([^|;]+)/i, 1]&.strip
  end
  raise "Missing/unknown catalog category at source row #{row['source_row']}" unless CATALOG_CATEGORY_DESCRIPTIONS.key?(category)

  {
    category: category,
    source_category: source_category,
    source_row: row.fetch('source_row').to_i,
    name: row.fetch('product_name').to_s.strip,
    size: row.fetch('size').to_s.strip,
    price: row.fetch('price').to_s.strip,
    notes: row.fetch('notes').to_s.strip
  }.freeze
end.freeze

def catalog_price(raw_price)
  value = raw_price.to_s.strip
  return if value.blank? || value == '—' || value == '-'

  match = value.match(/\$\s*([\d,]+(?:\.\d+)?)|([\d,]+(?:\.\d+)?)\s*FC\b/i)
  return unless match

  amount = match[1] || match[2]
  { amount: BigDecimal(amount.delete(',')), currency: match[1] ? 'usd' : 'fc' }
end

def catalog_note_variants(notes)
  notes.to_s.split(/[;|]/).filter_map do |fragment|
    next if fragment.match?(/\ACategory:/i)

    if (match = fragment.match(/\A\s*(?:(grd|pt)\s*)?\(([^)]+)\)\s*:\s*(.+)\z/i))
      price = catalog_price(match[3])
      next unless price

      size = [match[1]&.downcase, "(#{match[2].strip})"].compact.join(' ')
      { size: size, price: price, raw_price: match[3].strip }
    elsif (match = fragment.match(/\A\s*Parfum\s*:\s*(.+)\z/i))
      price = catalog_price(match[1])
      next unless price

      { size: 'Parfum (size not specified)', price: price, raw_price: match[1].strip }
    end
  end
end
