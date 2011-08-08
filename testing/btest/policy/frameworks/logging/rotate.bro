#
# @TEST-EXEC: bro -r %DIR/rotation.trace %INPUT 2>&1 | grep "test" >out
# @TEST-EXEC: for i in test.*.log; do printf '> %s\n' $i; cat $i; done >>out
# @TEST-EXEC: btest-diff out

module Test;

export {
	# Create a new ID for our log stream
	redef enum Log::ID += { Test };

	# Define a record with all the columns the log file can have.
	# (I'm using a subset of fields from ssh-ext for demonstration.)
	type Log: record {
		t: time;
		id: conn_id; # Will be rolled out into individual columns.
	} &log;
}

redef Log::default_rotation_interval = 1hr;
redef Log::default_rotation_postprocessor_cmd = "echo";

event bro_init()
{
	Log::create_stream(Test, [$columns=Log]);
}

event new_connection(c: connection)
	{
	Log::write(Test, [$t=network_time(), $id=c$id]);
	}
