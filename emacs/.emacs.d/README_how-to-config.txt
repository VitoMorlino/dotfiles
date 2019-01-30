If you already know what you want to change and how to change it, make the change in /.emacs.d/custom-config.org (not the .el file)

Half of the battle of configuring to one's liking is learning/knowing what is possible!
So, have a gander at emacs's Customize menu to see what can be done, and play around with settings within that menu.

Access emacs's built-in customize menu with M-x customize

When settings are changed from this customize menu, the corresponding code is automatically generated and placed at the bottom of "/.emacs.d/customize-auto-generated.el" (because that's where we told it to go in "/.emacs.d/custom-config.org")

After testing the generated code, if it is something you want to keep for the future, move the automatically generated code to custom-config.org (in an attempt to keep the auto-generated file as empty as possible)

Note: If code already exists with the changed variables (within customize-auto-generated.el), the existing code will be updated instead of the code being added to the bottom of the file.
