# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'IMAC Judge App Documentation'
copyright = '2023, IMAC, https://mini-iac.org'
author = 'IMAC-Org'
release = '0.5'
today_fmt = '%Y-%m-%d'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [ 'sphinx_rtd_theme' ]

#templates_path = ['_templates']
exclude_patterns = []

rst_epilog = '.. |project| replace:: %s' %project

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_file_suffix = '.html'
html_show_sphinx = False
#html_show_search_summary = False

epub_tocdepth = 3
epub_writing_mode = 'horizontal'

latex_theme = 'howto'