<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DataDocument extends Model
{
    protected $table='data_documents';

    public $fillable = ['id','member_id','filename'];

    function claim() {
        return $this->belongsTo('App\Models\DataClaim');
    }
}
