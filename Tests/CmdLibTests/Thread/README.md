#  <#Title#>

当我建立了一个command line项目想单纯写一个command line程序的时候，发现。

咦，为什么异步多线程始终无法输出结果。

只要是开辟了一个异步多线程，那就肯定是什么内容都输出不了了。

可能不是建立command line，而是应该建立cocoa application？

然后一试，果然！多线程运行成功！

https://www.cnblogs.com/chenyangsocool/p/5454789.html


服务质量(qos)类对要在调度队列上执行的工作进行分类。通过指定任务的质量，您可以指示其对应用程序的重要性。
在调度任务时，系统优先考虑具有较高服务等级的任务。
因为高优先级的工作比低优先级的工作执行得更快，并且需要更多的资源，所以它通常比低优先级的工作需要更多的精力。准确地为你的应用程序执行的工作指定适当的qos类，确保你的应用程序是响应和节能的。
