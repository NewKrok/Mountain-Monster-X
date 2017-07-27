package hpp.flixel.util;

import js.RegExp;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HPPTimeUtil 
{
	public static inline var TIME_FORMAT_HH_MM_SS_MS:String = 'hh:mm:ss.ms';
	public static inline var TIME_FORMAT_HH_MM_SS:String = 'hh:mm:ss';
	public static inline var TIME_FORMAT_HH_MM:String = 'hh:ss';
	public static inline var TIME_FORMAT_MM_SS_MS:String = 'mm:ss.ms';
	public static inline var TIME_FORMAT_MM_SS:String = 'mm:ss';

	public static function timeStampToFormattedTime( timeStamp:Float, timeFormat:String = HPPTimeUtil.TIME_FORMAT_HH_MM_SS ):String
	{
		var showHour:Bool = timeFormat.indexOf( 'hh' ) != -1;
		var showMinute:Bool = timeFormat.indexOf( 'mm' ) != -1;
		var showSecond:Bool = timeFormat.indexOf( 'ss' ) != -1;
		var showMilliSecond:Bool = timeFormat.indexOf( 'ms' ) != -1;

		var hour:String = "";
		if( showHour )
		{
			hour = Std.string( HPPTimeUtil.getHourFromTimeStamp( timeStamp ) );
			if( hour.length == 1 )
			{
				hour = '0' + hour;
			}
		}

		var minute:String = "";
		if( showMinute )
		{
			minute = Std.string( HPPTimeUtil.getMinuteFromTimeStamp( timeStamp ) );
			if( minute.length == 1 )
			{
				minute = '0' + minute;
			}
		}

		var second:String = "";
		if( showSecond )
		{
			second = Std.string( HPPTimeUtil.getSecondFromTimeStamp( timeStamp ) );
			if( second.length == 1 )
			{
				second = '0' + second;
			}
		}

		var millisecond:String = "";
		if( showMilliSecond )
		{
			millisecond = Std.string( HPPTimeUtil.getMilliSecondFromTimeStamp( timeStamp ) );
			if( millisecond.length == 1 )
			{
				millisecond = '00' + millisecond;
			}
			else if( millisecond.length == 2 )
			{
				millisecond = '0' + millisecond;
			}
		}

		var result:String = timeFormat;

		if ( showHour )
		{
			result = StringTools.replace( result, "hh", hour );
		}

		if ( showMinute )
		{
			result = StringTools.replace( result, "mm", minute );
		}
		
		if ( showSecond )
		{
			result = StringTools.replace( result, "ss", second );
		}

		if ( showMilliSecond )
		{
			result = StringTools.replace( result, "ms", millisecond );
		}

		return result;
	}

	public static function getHourFromTimeStamp( timeStamp:Float ):Int
	{
		return Math.floor( ( Math.floor( timeStamp / 1000 / 60 ) / 60 ) % 24 );
	}

	public static function getMinuteFromTimeStamp( timeStamp:Float ):Int
	{
		return Math.floor( Math.floor( timeStamp / 1000 / 60 ) % 60 );
	}

	public static function getSecondFromTimeStamp( timeStamp:Float ):Int
	{
		return Math.floor( ( timeStamp / 1000 ) % 60 );
	}

	public static function getMilliSecondFromTimeStamp( timeStamp:Float ):Int
	{
		return Math.floor( timeStamp % 1000 );
	}
}