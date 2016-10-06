# Databl

Databl is a javascript datatable interface for Ruby on Rails apps.

Steps to use:

1- Add your custom datatable ruby class
2- Define an instance method named ```datable_rows``` where you will query and process your data rows
3- Initialize a databl object with the ```params``` helper and if necessary some session specific data.
3- Use the ```tablize``` method to fetch and format your data rows

If you need to sort your data there are two methods provided to you that you can call in your ```datable_rows``` method:

* ```sort_column``` gives you the index number of the table header to sort by
* ```sort_direction``` ASC or DESC, sent when table header is clicked to sort

If you need the query term:

* ```query``` the query term that the user provides in the search box

You can also define a mapping between the header indices and sql fragment as a macro using ```column_names``` that takes a hash with keys
as the header index and values as the sql fragments

```ruby
ColumnNames = {
      1 => 'products.production_date',
      2 => 'products.supplier',
      3 => 'products.brand',
      default: 'products.name'
  }

column_names ColumnNames
```

* ```sort_column_name``` is the method that gives you the sql fragment depending on which header is selected to sort by

If you need to pass session or db related data to fetch records, you can provide them to the when initializing a databl object
in a hash passed in as the second argument:

* ```session_opts``` is the method to access session related data

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'databl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install databl

## Usage

```ruby
class ProductsDatatable < Databl::Base
  ColumnNames = {
        1 => 'products.production_date',
        2 => 'products.supplier',
        3 => 'products.brand',
        default: 'products.name'
    }
  
  column_names ColumnNames

  def databl_rows
    account = Account.find(session_opts[:account_id])
    if query.present?
      if sort_column > 0
        Product.search_by_account_with_query(account, query, sort_column_name, sort_direction)
      else
        Product.search_by_account_with_query(account, query)
      end
    else
      if sort_column > 0
        Product.search_by_account(account, sort_column_name, sort_direction)
      else
        Product.search_by_account(account)
      end
    end
  end
end
```

Lastly, you can create a template similar to ```products/example_action.databl``` and use the records fetched above
like the following:

```ruby
ProductsDatatable.new(params, account_id: current_user.account_id).datablize do |row|
  [
    '<i class="fa fa-tag"></i>',
    link_to(product.name, product),
    product.brand
  ]
end
```

You can pass in a block to ```datablize``` as seen here to format your results. Any further metadata like for example totals
calculated for columns to be presented can be provided in a hash as an argument to ```datablize```:

```ruby
ProductsDatatable.new(params, account_id: current_user.account_id).datablize(total_number_of_products: 100, total_number_of_brands: 35)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rendekarf/databl.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

