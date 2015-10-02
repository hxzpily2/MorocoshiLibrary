package net.morocoshi.common.timers 
{
	/**
	 * タスク
	 * 
	 * @author tencho
	 */
	public class TaskData 
	{
		/**識別用の名前*/
		public var name:String;
		/**初回処理を実行済みか*/
		public var isInit:Boolean;
		/**初回処理*/
		public var init:Function;
		/**処理内容*/
		public var task:Function;
		/**ループ時の条件文*/
		public var conditional:Function;
		/**非ループ時の引数*/
		public var args:Array;
		
		public function TaskData() 
		{
		}
		
	}

}