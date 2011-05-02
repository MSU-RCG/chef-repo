name "basic_rvm"
description "Basic, system-wide RVM installation. Chef compatible."
run_list ['rvm']
default_attributes({ :rvm => {
                       :version => "1.6.5",
                       :default_ruby => "ruby-1.8.7",
                       :rubies => ["ruby-1.9.2"],
                       :global_gems => [
                                        {:name => "bundler"},
                                        {:name => "rake"},
                                        {:name => "chef"}
                                       ]
                     }
                   })
