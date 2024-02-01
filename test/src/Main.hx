class Main
{
    static function main()
	{
		var runner = new utest.Runner();
		
        runner.addCase(new HtmlTest());
		runner.addCase(new XmlTest());

        utest.ui.Report.create(runner);
        runner.run();
	}
}
